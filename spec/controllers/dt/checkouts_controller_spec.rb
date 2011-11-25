require File.dirname(__FILE__) + '/../../spec_helper'

describe Dt::CheckoutsController do
  let(:investment) { Factory.build(:investment) }
  let(:gift) { Factory.build(:gift) }
  let(:cart_items) { [investment, gift] }
  let(:user) { Factory(:user) }
  let(:cart) { Cart.create! }
  let(:order) { Factory(:order, :email => "user@example.com", :cart => cart, :credit_card_payment => 0) }

  before do
    cart_items.each {|i| cart.add_item(i) }
    order.total = cart.total
    controller.stub!(:find_cart).and_return(cart)
    controller.stub!(:find_order).and_return(order)
  end

  it "should extend DtApplicationController" do
    controller.should be_kind_of(DtApplicationController)
  end

  %w(new create show edit update destroy ).each do |m|
    it "should respond to #{m}" do
      controller.should respond_to(m)
    end
  end
  %w(index).each do |m|
    it "should not respond to #{m}" do
      controller.should_not respond_to(m)
    end
  end

  it "should define @checkout_steps as %w(upowered billing account_signup credit_card confirm receipt)" do
    post 'create', :order => {}
    controller.instance_variable_get(:@checkout_steps).should == %w(upowered billing account_signup credit_card confirm receipt)
  end

  describe "create action" do
    before do
      Order.stub!(:new).and_return(order)
      controller.stub!(:find_order).and_return(nil)
      controller.stub!(:validate_order).and_return(true)
    end

    it "should redirect to \"billing\" if no current_step" do
      do_request
      response.should redirect_to(edit_dt_checkout_path(:step => "billing"))
    end

    it "should find_cart" do
      controller.should_receive(:find_cart).once.and_return(cart)
      do_request
    end

    it "should find_order" do
      controller.should_receive(:find_order).at_least(:once).and_return(nil)
      do_request
    end

    it "should redirect to edit action if an existing order is found" do
      controller.should_receive(:find_order).and_return(order)
      do_request
      response.should redirect_to(edit_dt_checkout_path)
    end

    it "should initialize_new_order" do
      controller.should_receive(:initialize_new_order).and_return(order)
      do_request
    end

    it "should redirect to edit action if an existing order is found" do
      controller.should_receive(:find_order).and_return(order)
      do_request
      response.should redirect_to(edit_dt_checkout_path)
    end

    it "should validate the order" do
      controller.should_receive(:validate_order).and_return(true)
      do_request
    end

    it "should save the order" do
      order.should_receive(:save).and_return(true)
      do_request
    end

    it "should note save the order if it's not valid" do
      controller.should_receive(:validate_order).and_return(false)
      order.should_receive(:save).never
      do_request
    end

    it "should put the order_id in the session" do
      do_request
      session[:order_id].should == order.id
    end

    it "should not put the order_id in the session for an invalid order" do
      controller.should_receive(:validate_order).and_return(false)
      do_request
      session[:order_id].should == nil
    end

    it "should render the upowered (first step) template if the order can't save" do
      order.should_receive(:save).and_return(false)
      do_request
      response.should render_template("upowered")
    end

    describe "with a gift card" do
      describe "that has a balance larger than the total" do
        let(:gift_card) { Factory(:gift, :amount => order.total + 1, :balance => order.total + 1) }
        before do
          order.total = cart.total
          session[:gift_card_id] = gift_card.id
        end
        it "should set gift_card_payment to order.total when the user has no balance" do
          gift_card.update_attributes(:amount => order.total + 1, :balance => order.total + 1)
          user.stub!(:balance).and_return(0)
          do_request
          order.gift_card_payment.should == order.total
        end
        it "should keep credit_card_payment to 0 when the user has no balance and has a gift card larger than the total" do
          order.credit_card_payment = 0
          new_balance = order.total + 1
          gift_card.update_attributes(:amount => new_balance, :balance => new_balance)
          user.stub!(:balance).and_return(0)
          do_request
          order.credit_card_payment.should == 0
        end
      end
    end
    describe "with a logged in user" do
      before do
        controller.stub!(:logged_in?).and_return(true)
        controller.stub!(:current_user).and_return(user)
        user.stub!(:balance).and_return(0)
      end
      it "should check the user's balance" do
        user.should_receive(:balance)
        do_request
      end
      it "should set credit_card_payment to order.total when the user has no balance" do
        do_request
        order.credit_card_payment.should == order.total
      end
      describe "with a gift card" do
        let(:gift_card) { Factory(:gift, :amount => order.total - 1) }
        before do
          session[:gift_card_id] = gift_card.id
        end
        it "should set gift_card_payment to gift_card_balance when the user has no balance and has a gift card" do
          user.stub!(:balance).and_return(0)
          do_request
          order.gift_card_payment.should == gift_card.balance
        end
        it "should set credit_card_payment to order.total-gift_card_balance when the user has no balance and has a gift card" do
          user.stub!(:balance).and_return(0)
          do_request
          order.credit_card_payment.should == 1
        end
      end
    end

    def do_request(params = {})
      params = order.attributes.delete_if{|k,v| v == 0 || v.blank? }.merge(params)
      post 'create', :order => params
    end
  end

  describe "update action" do
    before do
      controller.stub!(:validate_order).and_return(true)
      @step = nil
    end
    it "should redirect to the upowered step" do
      do_request
      response.should redirect_to(edit_dt_checkout_path(:step => "upowered"))
    end

    describe "on the credit_card step" do
      before do
        @step = "credit_card"
        order.stub!(:run_transaction).and_return(true)
      end

      it "should call do_credit_card" do
        controller.should_receive(:do_credit_card)
        do_request
      end
      it "next_step should be confirm" do
        do_request
        controller.send(:next_step).should == 'confirm'
      end

      it "should redirect to dt_checkout_path if it's valid and complete" do
        controller.should_receive(:validate_order).and_return(true)
        controller.stub!(:do_action).and_return(true)
        order.should_receive(:complete?).any_number_of_times.and_return(true)
        do_request
        response.should redirect_to(dt_checkout_path(:order_number => order.order_number))
      end
    end

    describe "on the confirm step" do
      before do
        @step = "confirm"
        order.stub!(:run_transaction).and_return(true)
      end

      describe "do_confirm method" do
        it "should process the credit card" do
          order.total = 10
          order.credit_card_payment = order.total
          order.should_receive(:run_transaction).and_return(true)
          do_request
        end
        it "should update the send_now on any stale gifts (with send_at values in the past)" do
          now = Time.now
          Time.stub!(:now).and_return(now)
          gift.send_at = Time.now - 15.minutes
          gift.send_email = true
          cart.stub!(:gifts).and_return([gift])
          gift.should_receive(:send_at=).with(Time.now + 1.minute)
          gift.stub!(:valid?).and_return(true)
          do_request
        end
        it "should not update the send_now on any non-stale gifts (with send_at values in the future)" do
          now = Time.now
          Time.stub!(:now).and_return(now)
          gift.send_email = true
          gift.stub!(:send_at).and_return(Time.now + 3.seconds)
          cart.stub!(:gifts).and_return([gift])
          gift.should_receive(:send_at=).never
          do_request
        end
        it "should not update the send_now on any gifts that aren't being sent (send_email = false)" do
          now = Time.now
          Time.stub!(:now).and_return(now)
          gift.send_email = false
          cart.stub!(:gifts).and_return([gift])
          gift.should_receive(:send_at=).never
          do_request
        end
        it "should save the gifts from the cart into the db" do
          gift1 = Factory(:gift)
          gift2 = Factory(:gift)
          cart.should_receive(:gifts).twice.and_return([gift1, gift2])
          order.should_receive(:gifts=).with([gift1, gift2])
          do_request
        end
        it "should save the investments from the cart into the db" do
          investment1 = Factory(:investment)
          investment2 = Factory(:investment)
          cart.should_receive(:investments).and_return([investment1, investment2])
          order.should_receive(:investments=).with([investment1, investment2])
          do_request
        end
        it "should save the deposits from the cart into the db" do
          deposit1 = Factory(:deposit)
          deposit2 = Factory(:deposit)
          cart.should_receive(:deposits).and_return([deposit1, deposit2])
          order.should_receive(:deposits=).with([deposit1, deposit2])
          do_request
        end
        it "should mark the order as complete" do
          order.should_receive(:update_attributes!).with({:complete => true})
          do_request
        end
        it "should remove the order_id from the session" do
          session[:order_id] = 1
          do_request
          session[:order_id].should be_nil
        end
        it "should add the order_number into the session" do
          session[:order_number].should be_nil
          do_request
          session[:order_number].should == [order.order_number]
        end
        it "should not process a credit card when not paying from it" do
          order.stub!(:total).and_return(55)
          order.stub!(:credit_card_payment).and_return(0)
          order.stub!(:credit_card_payment?).and_return(false)
          order.should_receive(:run_transaction).never
          do_request
        end
        describe "when paying with a gift card" do
          let(:gift_card) { Factory(:gift, :amount => cart.total) }
          before do
            session[:gift_card_id] = gift_card.id
            order.credit_card_payment = 0
            order.total = cart.total
            order.gift_card_balance = gift_card.balance
            order.gift_card_payment = gift_card.balance
          end
          it "should not run a credit card when paying with a gift card" do
            order.should_receive(:run_transaction).never
            do_request
          end
          it "should add the gift_card_payment_id to the order when paying with a gift_card" do
            do_request
            order.gift_card_payment_id.should == gift_card.id
          end
          it "should save the gift_card_payment to the order when paying with a gift_card" do
            do_request
            order.gift_card_payment.should == gift_card.balance
          end
          it "should reduce the gift_card balance when paying with a gift_card" do
            do_request
            gift_card.reload
            gift_card.balance.should == order.total - order.gift_card_payment
          end
          it "should remove the gift_card_id from the session" do
            do_request
            session[:gift_card_id].should be_nil
          end
          it "should remove the gift_card_balance from the session" do
            do_request
            session[:gift_card_balance].should be_nil
          end
          it "should pickup the gift" do
            gift_card.picked_up_at.should be_nil
            do_request
            gift_card.reload
            gift_card.picked_up_at.should_not be_nil
          end
        end
      end
      describe "do_confirm method with invalid transaction" do
        before do
          order.stub!(:run_transaction).and_return(false)
          order.total = 10
          order.credit_card_payment = order.total
        end
        it "should not mark the order as complete or save the deposits, investments or gifts if the transaction isn't successful" do
          order.should_receive(:run_transaction).and_return(false)
          order.should_receive(:update_attributes).never
          order.should_receive(:gifts=).never
          order.should_receive(:deposits=).never
          order.should_receive(:investments=).never
          do_request
        end
        it "should not empty the cart, remove the order_id or add the order_number" do
          session[:order_id] = 1
          session[:order_number].should be_nil
          cart.should_receive(:empty!).never
          do_request
          session[:order_id].should == 1
          session[:order_number].should be_nil
        end
      end
    end

    def do_request(params = {})
      params = {:step => @step}.merge(params)
      put "update", params
    end
  end
end
