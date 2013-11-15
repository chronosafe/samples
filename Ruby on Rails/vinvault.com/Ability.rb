class Ability

  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user (not logged in)
    can :access, :rails_admin if user.has_role? :admin
    can :bulk, Pattern if Settings.bulk_enabled
    can :manage, :all if user.has_role? :admin
    can :dashboard if user.has_role? :admin
    can [:create, :show, :index], Decode if user.has_role? :bronze
    can [:create, :show, :index], Decode if user.has_role? :silver
    can [:create, :show, :index], Decode if user.has_role? :gold
    can [:create, :show, :index], Decode if user.has_role? :platinum
    can [:create, :show, :index], Decode if user.has_role? :vinhunter
    can [:show, :index], Decode if user.has_role? :guest
  end
end