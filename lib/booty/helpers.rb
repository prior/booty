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
    # zip files get priority
    def decompose_node(pathname)
      pathname.children.partition do |child|
        child.directory?
      end.map do |list|
        list.select{|i| i.basename.to_s!='.gitignore'}.sort do |a,b|
          v1, v2 = [a,b].map{|p| p.extname == '.zip' ? 0 : 1}
          retval = v1<=>v2
          retval = a.to_s.downcase<=>b.to_s.downcase if retval==0
          retval
        end
      end
    end
    
  end
end


require 'action_view'
ActionView::Base.send(:include, Booty::Helpers)
