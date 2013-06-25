# encoding: utf-8
#--
#   Copyright (C) 2012-2013 Gitorious AS and/or its subsidiary(-ies)
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
require "dolt/sinatra/base"
require "libdolt/view/multi_repository"
require "gitorious/view/dolt_url_helper"

module Gitorious
  class RepositoryBrowser < ::Dolt::Sinatra::Base
    include ::Dolt::View::MultiRepository
    include Gitorious::View::DoltUrlHelper

    def self.instance; @instance; end
    def self.instance=(instance); @instance = instance; end

    # Implementing this method and returning true means that
    # Dolt will redirect any requests to refs to the actual commit
    # oid, e.g.:
    #   GET /gitorious/mainline/source/master:
    #   -> 302 /gitorious/mainline/source/2d4e282d02f438043fc425cc99a781774d22561a:
    def redirect_refs?; true; end

    get "/*/source/*:*" do
      repo, ref, path = params[:splat]
      env["dolt"] = { :repository => repo }
      tree_entry(repo, ref, path)
    end

    get "/*/source/*" do
      force_ref(params[:splat], "source")
    end

    get "/*/raw/*:*" do
      repo, ref, path = params[:splat]
      env["dolt"] = { :repository => repo }
      raw(repo, ref, path)
    end

    get "/*/raw/*" do
      force_ref(params[:splat], "raw")
    end

    get "/*/blame/*:*" do
      repo, ref, path = params[:splat]
      env["dolt"] = { :repository => repo }
      blame(repo, ref, path)
    end

    get "/*/blame/*" do
      force_ref(params[:splat], "blame")
    end

    get "/*/history/*:*" do
      repo, ref, path = params[:splat]
      env["dolt"] = { :repository => repo }
      history(repo, ref, path, (params[:commit_count] || 20).to_i)
    end

    get "/*/history/*" do
      force_ref(params[:splat], "history")
    end

    get "/*/refs" do
      repo = params[:splat].first
      env["dolt"] = { :repository => repo }
      refs(repo)
    end

    get "/*/tree_history/*:*" do
      repo, ref, path = params[:splat]
      env["dolt"] = { :repository =>  repo }
      tree_history(repo, ref, path)
    end

    get %r{/(.*)/archive/(.*)?\.(tar\.gz|tgz|zip)} do
      begin
        repo, ref, format = params[:captures]
        env["dolt"] = { :repository =>  repo }
        filename = actions.archive(repo, ref, format)
        add_sendfile_headers(filename, format)
        body("")
      rescue Exception => err
        error(err, repo, ref)
      end
    end

    private
    def add_sendfile_headers(filename, format)
      basename = File.basename(filename)
      user_path = basename.gsub("/", "_").gsub('"', '\"')

      response.headers["content-type"] = format == "zip" ? "application/x-zip" : "application/x-gzip"
      response.headers["content-disposition"] = "Content-Disposition: attachment; filename=\"#{user_path}\""

      if Gitorious.frontend_server == "nginx"
        response.headers["x-accel-redirect"] = "/tarballs/#{basename}"
      else
        response.headers["x-sendfile"] = filename
      end
    end

    def force_ref(args, action)
      repo = args.shift
      ref = resolve_repository(repo).head_candidate_name
      redirect("/#{repo}/#{action}/#{ref}:" + args.join)
    end
  end
end