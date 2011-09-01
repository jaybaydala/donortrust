# Put into checkout as a default option: 
# - this means reworking the subscription to only take subscription items instead of the whole cart)
# - beside the mailing list opt in ("Join UPowered - for the monthly price of a cup of coffee, help fund the organization that's ending poverty")
# - if they leave it checked, link to "Adjust your monthly amount", which links back to the UPowered edit page (4 buttons, etc)
# 
# Multiple U:Powered Tiers (popup or separate page):
# - $5, $10, $25, $100, you choose (4 buttons and one text field a button

Feature: UPowered as a default checkout addition
  When a user has added an item to their cart and proceeds to checkout
  We would like them to have UPowered auto-added to their order
  So that they can see how to support the organization
