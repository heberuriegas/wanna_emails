module ControllerMacros
  def sign_in_user
    @user = create :user
    sign_in @user
  end
end