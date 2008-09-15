Feature: Checkout with a Gift Card Balance
	In order to spend my gift card
	As a gift receiver
	I want to use my gift card balance to pay for my cart contents
		
	Scenario: Checking out with a gift card amount less than the cart totals
		Given that I have opened a gift
		When I am on the payment step of the checkout process
		Then the gift card amount will be taken off of the cart total amount
		And the remaining balance should have to go on their credit card
		And I will be asked for my credit card information
		And the gifter will receive an email notifying that the gift has been opened
		
	Scenario: Checking out with a gift card amount that is greater than cart totals
		Given that I have opened a gift
		When I am on the payment step of the checkout process
		Then I can pay my cart total off with my gift card amount
		And not be asked for my credit card information
		And the gifter will receive an email notifying that the gift has been opened
	
	Scenario: Checking out with a gift card amount that equals cart totals
		Given that I have opened a gift
		When I am on the payment step of the checkout process
		Then I can pay my cart total off with my gift card amount
		And not be asked for my credit card information
		And the gifter will receive an email notifying that the gift has been opened
	