require File.join(File.dirname(__FILE__),'lib/commands.rb')

Rails::Generator::Commands::Destroy.class_eval do
  def booty_map(booty_map, action)
    secret = booty_map.delete_secret(options[:booty_controller_name], action)
    logger.purge "#{action} => #{secret}"
  end
end

class BootyGenerator < Rails::Generator::NamedBase
  default_options :booty_controller_name => 'booty'

  def initialize(runtime_args, runtime_options = {})
    # a homemade hacked super to skip parent and go to grandparent
    self.class.superclass.superclass.instance_method(:initialize).bind(self).call(runtime_args, runtime_options)

    # at least one action is required.
    usage if runtime_args.empty?

    @args = runtime_args.dup
    assign_names!(options[:booty_controller_name])
    @booty_map = Booty::BootyMap.new
  end



  def manifest
    record do |m|

      # Check for class naming collisions.
      # m.class_collisions class_path, "#{class_name}Controller", "#{class_name}ControllerTest", "#{class_name}Helper"

      # Controller, helper, views, layout, and test directories.
      m.directory File.join('app/controllers', class_path)
      m.directory File.join('app/helpers', class_path)
      m.directory File.join('app/views', class_path, file_name)
      m.directory File.join('test/functional', class_path)
      m.directory File.join('app/views/layouts', class_path)
      m.directory File.join('public', class_path, file_name)

      # Controller class, functional test, helper class, and layout.
      m.template 'controller.rb',
                  File.join('app/controllers',
                            class_path,
                            "#{file_name}_controller.rb")
      m.template 'functional_test.rb',
                  File.join('test/functional',
                            class_path,
                            "#{file_name}_controller_test.rb")
      m.template 'helper.rb',
                  File.join('app/helpers',
                            class_path,
                            "#{file_name}_helper.rb")
      m.template 'layout.html.haml',
                  File.join('app/views/layouts',
                            class_path,
                            "#{file_name}.html.haml")
      m.template '_file_tree.html.haml',
                 File.join('app/views/',
                           class_path, 
                           file_name,
                           '_file_tree.html.haml')

      actions.each do |action|
        path = File.join('app/views', class_path, file_name, "#{action}.html.haml")
        m.template 'view.html.haml', path, :assigns => { :action => action, :path => path }

        m.booty_map(@booty_map, action)
        m.booty_route(@booty_map, action)
        m.directory File.join('public', class_path, file_name, action, @booty_map.create_secret(options[:booty_controller_name],action,options[:pretend]))
      end

    end
  end

  protected

    def add_options!(opt)
      opt.on('-nNAME','--name=NAME','specify booty controller name (default:booty)') {|name| options[:booty_controller_name] = name}
    end

    def banner
      "Usage: #{$0} #{spec.name} silo1 [, silo2, silo3, ..]"
    end
end
