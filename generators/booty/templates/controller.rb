class <%= class_name %>Controller < Booty::Controller
<% for action in actions -%>
  def <%= action %>
  end

<% end -%>
end
