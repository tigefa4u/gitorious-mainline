# encoding: utf-8
#--
#   Copyright (C) 2014 Gitorious AS
#
#   This program is free software: you can redistribute it and/or modify
#   it under the terms of the GNU Affero General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU Affero General Public License for more details.
#
#   You should have received a copy of the GNU Affero General Public License
#   along with this program.  If not, see <http://www.gnu.org/licenses/>.
#++
require "test_helper"
require "destroy_membership"

class DestroyMembershipTest < ActiveSupport::TestCase
  def setup
    @membership = memberships(:a_team_owner)
  end

  should "destroy membership if user isn't group's creator" do
    @membership.group.creator = users(:moe)
    outcome = DestroyMembership.new(@membership).execute

    assert outcome.success?
  end

  should "not destroy membership if user is group's creator" do
    @membership.group.creator = @membership.user
    outcome = DestroyMembership.new(@membership).execute

    refute outcome.success?
  end
end
