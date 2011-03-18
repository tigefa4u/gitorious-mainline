# encoding: utf-8
#--
#   Copyright (C) 2011 Gitorious AS
#   Copyright (C) 2009 Nokia Corporation and/or its subsidiary(-ies)
#   Copyright (C) 2008 Johan Sørensen <johan@johansorensen.com>
#   Copyright (C) 2008 David A. Cuadrado <krawek@gmail.com>
#   Copyright (C) 2008 Tor Arne Vestbø <tavestbo@trolltech.com>
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

class CommitDiffsController < ApplicationController
  before_filter :find_project_and_repository
  before_filter :check_repository_for_commits
  skip_before_filter :public_and_logged_in
  skip_before_filter :require_current_eula
  skip_after_filter :mark_flash_status
  renders_in_site_specific_context

  def index
    @comments = []
    @diffmode = params[:diffmode] == "sidebyside" ? "sidebyside" : "inline"
    @git = @repository.git

    unless @commit = @git.commit(params[:id])
      render_not_found and return
    end

    @root = Breadcrumb::Commit.new(:repository => @repository, :id => @commit.id_abbrev)
    @diffs = @commit.parents.empty? ? [] : @commit.diffs
    @committer_user = User.find_by_email_with_aliases(@commit.committer.email)
    @author_user = User.find_by_email_with_aliases(@commit.author.email)
    headers["Cache-Control"] = "public, max-age=315360000"

    render :layout => !request.xhr?
  end
end
