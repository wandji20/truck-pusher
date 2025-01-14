module AuthenticationHelper
  def sign_in(user)
    if respond_to?(:visit) # System specs
      expect(page).to have_no_content(/Deliveries/)
      visit login_path(params: { enterprise_name: user.enterprise.name })
      fill_in "telephone", with: user.telephone
      fill_in "password", with: user.password
      find("input[type='submit']").click

      expect(page).to have_content(/Deliveries/)
    else # Controller specs
      session[:user_id] = user.id
    end
  end
end

RSpec.configure do |config|
  config.include AuthenticationHelper, type: :system
  config.include AuthenticationHelper, type: :controller
end
