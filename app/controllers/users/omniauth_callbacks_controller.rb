class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  
  def action_missing(provider)
    if !User.authentications.index(provider).nil?
      omniauth = request.env["omniauth.auth"]
      #omniauth = env["omniauth.auth"]
    
      if current_user #or User.find_by_email(auth.recursive_find_by_key("email"))
        current_user.authentications.find_or_create_by_provider_and_uid(omniauth['provider'], omniauth['uid'])
         flash[:notice] = "Authentication successful"
         redirect_to edit_user_registration_path
      else
        authentication = Authentication.where(:provider => omniauth['provider'], :uid => omniauth['uid']).first
        puts"@@@@AUTHEN@@@@#{authentication}" 
        if authentication
          flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => omniauth['provider']
          sign_in_and_redirect(:user, authentication.user)
        else
          puts"@@@MANIVANNAN@@"
          #create a new user
          unless omniauth.recursive_find_by_key("email").blank?
            user = User.find_or_initialize_by(:email => omniauth.recursive_find_by_key("email"))
          else
            user = User.new
          end
          
          user.apply_omniauth(omniauth)
          #user.confirm! #unless user.email.blank?

          if user.save
            flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => omniauth['provider'] 
            sign_in_and_redirect(:user, user)
          else
            session[:omniauth] = omniauth.except('extra')
            redirect_to new_user_registration_url
          end
        end
      end
    end
  end
end
