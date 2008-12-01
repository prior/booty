module Booty
  module Helpers

    # creates link to pathname.
    # assumes pathname is in public rails dir somewhere
    def link_to_public_file(pathname)
      @@public_root ||= (Pathname(::RAILS_ROOT) + 'public')
      relative_path = pathname.relative_path_from(@@public_root)
      link_to(pathname.basename, "/#{relative_path}")
    end

    # generates [dirs,files] array,
    # where dirs and files are each sorted arrays
    def decompose_node(pathname)
      pathname.children.partition{|c| c.directory?}.map{|l| l.sort}
    end
    
  end
end


require 'action_view'
ActionView::Base.send(:include, Booty::Helpers)
