#-- copyright
# OpenProject is a project management system.
# Copyright (C) 2014 the OpenProject Foundation (OPF)
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License version 3.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#
# See doc/COPYRIGHT.md for more details.
#++

require File.expand_path('../../spec_helper', __FILE__)


describe WebhooksController, :type => :controller do
  let(:hook) { double(OpenProject::Webhooks::Hook) }
  let(:user) { double(User).as_null_object }

  describe '#handle_hook' do
    before do
      expect(OpenProject::Webhooks).to receive(:find).with('testhook').and_return(hook)
      allow(controller).to receive(:find_current_user).and_return(user)
    end

    after do
      # ApplicationController before filter user_setup sets a user
      User.current = nil
    end

    it 'should be successful' do
      expect(hook).to receive(:handle)

      post :handle_hook, :hook_name => 'testhook'

      expect(response).to be_success
    end

    it 'should call the hook with a user' do
      expect(hook).to receive(:handle) { |env, params, user|
        expect(user).to equal(user)
      }

      post :handle_hook, :hook_name => 'testhook'
    end

  end
end
