# encoding: utf-8
#--
#   Copyright (C) 2013 Gitorious AS
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

class AvatarsControllerTest < ActionController::TestCase
  should_render_in_global_context

  context "destroy" do
    should "be able to delete his avatar" do
      user = users(:johan)
      user.update_attribute(:avatar_file_name, "foo.png")
      login_as :johan

      delete :destroy, :id => user.to_param

      assert_redirected_to edit_user_path(user)
      assert !user.reload.avatar?
    end
  end
end
