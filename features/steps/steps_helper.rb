def login
  @user = create_user
  @user.activate
  post("/dt/session", {:login => @user.login, :password => @user.password})
end

