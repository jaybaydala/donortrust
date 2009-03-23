xml.instruct! :xml, :version => "1.0"
xml.account  do
  xml.gifts do
    for gift in @user.gifts
      xml.gift do
        xml.amount(gift.amount)
        xml.project(gift.project.name)
        xml.project_link(dt_project_path(gift.project))
        xml.gifted_to(gift.to_name)
      end
    end
  end

  xml.investments do
    for investment in @user.investments
      xml.investment do 
      
      end
    end
  end
  
  xml.deposits do
    for deposit in @user.deposits
      xml.deposit do
      
      end
    end
  end
  
  xml.pledges do
    for pledge in @user.pledges
      xml.pledge do
      
      end
    end
  end
end