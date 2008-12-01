Rails::Generator::Commands::Create.class_eval do
  def booty_map(booty_map, action)
    secret = booty_map.create_secret(options[:booty_controller_name], action, options[:pretend])
    logger.hide "#{action} => #{secret}"
  end

  def booty_route(booty_map, action)
    sentinel = 'ActionController::Routing::Routes.draw do |map|'
    route = booty_map.route(options[:booty_controller_name],action,options[:pretend])
    logger.route route
    unless options[:pretend]
      gsub_file 'config/routes.rb', /(#{Regexp.escape(sentinel)})/mi do |match|
        "#{match}\n  #{route}\n"
      end
    end
  end

end

Rails::Generator::Commands::Destroy.class_eval do
  def booty_map(booty_map, action)
    secret = booty_map.delete_secret(options[:booty_controller_name], action, options[:pretend])
    logger.purge "#{action} => #{secret}"
  end

  def booty_route(booty_map, action)
    route = booty_map.route(options[:booty_controller_name],action,options[:pretend])

    look_for = "\n  #{route}\n"
    logger.route route
    gsub_file 'config/routes.rb', /(#{look_for})/mi, '' unless options[:pretend]
  end
  
end
 
Rails::Generator::Commands::List.class_eval do
  def booty_map(booty_map, action)
    logger.route "#{action} => #{booty_map.secret(options[:booty_controller_name],action)}"
  end

  def booty_route(booty_map, action)
    route = booty_map.route(options[:booty_controller_name],action)
    logger.route route
  end
end
