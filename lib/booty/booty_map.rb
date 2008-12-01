require 'yaml'
require 'digest'
require 'base64'
require 'pathname'

module Booty
  class BootyMap
    FILENAME = File.join(::RAILS_ROOT, 'config/booty_map.yaml')

    def self.booty_map
      @@booty_map ||= BootyMap.new
    end

    def delete_secret(controller, action, pretend = false)
      @booty_map[controller] ||= {}
      secret = @booty_map[controller].delete(action)
      @booty_map.delete(controller) if @booty_map[controller].length == 0
      save if !pretend
      secret
    end

    def create_secret(controller, action, pretend = false)
      sub_hash = (@booty_map[controller] ||= {})
      if !(secret = sub_hash[action])
        secret = sub_hash[action] = generate_secret(action)
        save if !pretend
      end
      secret
    end

    def secret(controller, action)
      sub_hash = (@booty_map[controller] ||= {})
      sub_hash[action]
    end

    def pathname(controller, action)
      Pathname(::RAILS_ROOT) + 'public' + controller + action + secret(controller,action)
    end

    def route(controller, action, pretend = false)
      secret = create_secret(controller,action, pretend)
      pieces = []
      pieces << "map.connect '#{secret}'"
      pieces << ":controller=>'#{controller}'"
      pieces << ":action=>'#{action}'"
      pieces << ":id=>'#{secret}'"
      pieces.join(', ')
    end

    def exists?(controller, action, secret)
      sub_hash = (@booty_map[controller] || {})
      sub_hash[action] ? sub_hash[action] == secret : false
    end

  protected

    def initialize
      @booty_map = {}
      load
    end

    def load
      @booty_map = File.exists?(FILENAME) ? (YAML::load(File.read(FILENAME)) || {}) : {}
    end

    def save
      File.open(FILENAME,"w") {|f| f.write @booty_map.to_yaml}
    end

    def generate_secret(action)
      sha = Digest::SHA2.new(512)
      now = Time.now
      sha << now.to_s
      sha << String(now.usec)
      sha << String(rand(0))
      sha << String($$)
      sha << action
      Base64.encode64(sha.digest).delete("/+=\n")[0..20]
    end

  end
end

 
