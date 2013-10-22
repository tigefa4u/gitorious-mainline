# encoding: utf-8
#--
#   Copyright (C) 2012 Gitorious AS
#   Copyright (C) 2009 Nokia Corporation and/or its subsidiary(-ies)
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

module Gitorious
  class AuthorizedFilter
    attr_reader :current_user

    def initialize(current_user)
      @current_user = current_user
    end

    def filter(collection)
      filter_authorized(current_user, collection)
    end

    def filter_paginated(page, per_page = 30, collection_count = nil, &block)
      page = 1 if page.nil?
      WillPaginate::Collection.create(page, per_page) do |pager|
        result = filter(block.call(page))

        # inject the result array into the paginated collection:
        pager.replace(result)

        unless pager.total_entries
          # the pager didn't manage to guess the total count, do it manually
          pager.total_entries = result.first.nil? ? 0 : collection_count || result.first.class.count
        end
      end
    end

    private

    include Gitorious::Authorization
  end
end
