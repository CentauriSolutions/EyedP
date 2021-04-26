# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::UsersController, type: :controller do
  let(:user) { User.create!(username: 'user', email: 'user@localhost', password: 'test1234') }

  let(:empty_key) { ApiKey.create }
  let(:api_key) { ApiKey.create(capabilities_mask: ApiKey::CAPABILITIES.values.sum) }

  describe 'list groups' do
    context 'missing key' do
      it 'does not list users' do
        get :index
        expect(response.status).to eq(400)
      end

      context 'Edit' do
        it 'can not edit the name' do
          expect(user.name).to eq(nil)
          post(:update, params: { id: user.id, user: { name: 'Test name' } })

          expect(response.status).to eq(400)
          user.reload
          expect(user.name).to eq(nil)
        end

        it 'can not edit the username' do
          expect(user.username).to eq('user')
          post(:update, params: { id: user.id, user: { username: 'testname' } })

          expect(response.status).to eq(400)
          user.reload
          expect(user.username).to eq('user')
        end

        it 'can not edit the email' do
          expect(user.email).to eq('user@localhost')
          post(:update, params: { id: user.id, user: { email: 'user2@localhost' } })

          expect(response.status).to eq(400)
          user.reload
          expect(user.email).to eq('user@localhost')
        end
      end
    end
    context 'invalid API key' do
      it 'does not list users' do
        get :index, params: { api_key: 'nope' }
        expect(response.status).to eq(403)
      end

      context 'Edit' do
        it 'can not edit the name' do
          expect(user.name).to eq(nil)
          post(:update, params: { api_key: 'nope', id: user.id, user: { name: 'Test name' } })

          expect(response.status).to eq(403)
          user.reload
          expect(user.name).to eq(nil)
        end

        it 'can not edit the username' do
          expect(user.username).to eq('user')
          post(:update, params: { api_key: 'nope', id: user.id, user: { username: 'testname' } })

          expect(response.status).to eq(403)
          user.reload
          expect(user.username).to eq('user')
        end

        it 'can not edit the email' do
          expect(user.email).to eq('user@localhost')
          post(:update, params: { api_key: 'nope', id: user.id, user: { email: 'user2@localhost' } })

          expect(response.status).to eq(403)
          user.reload
          expect(user.email).to eq('user@localhost')
        end
      end
    end

    context 'Valid API key without permission' do
      it 'does not list users' do
        get :index, params: { api_key: empty_key.key }
        expect(response.status).to eq(403)
      end

      context 'Edit' do
        it 'can not edit the name' do
          expect(user.name).to eq(nil)
          post(:update, params: { api_key: empty_key.key, id: user.id, user: { name: 'Test name' } })

          expect(response.status).to eq(403)
          user.reload
          expect(user.name).to eq(nil)
        end

        it 'can not edit the username' do
          expect(user.username).to eq('user')
          post(:update, params: { api_key: empty_key.key, id: user.id, user: { username: 'testname' } })

          expect(response.status).to eq(403)
          user.reload
          expect(user.username).to eq('user')
        end

        it 'can not edit the email' do
          expect(user.email).to eq('user@localhost')
          post(:update, params: { api_key: empty_key.key, id: user.id, user: { email: 'user2@localhost' } })

          expect(response.status).to eq(403)
          user.reload
          expect(user.email).to eq('user@localhost')
        end
      end
    end

    context 'valid API key' do
      it 'lists users' do
        get :index, params: { api_key: api_key.key }
        expect(response.status).to eq(200)
      end

      context 'Edit' do
        it 'can edit the name' do
          expect(user.name).to eq(nil)
          post(:update, params: { api_key: api_key.key, id: user.id, user: { name: 'Test name' } })
          user.reload
          expect(user.name).to eq('Test name')
        end

        it 'can edit the username' do
          expect(user.username).to eq('user')
          post(:update, params: { api_key: api_key.key, id: user.id, user: { username: 'testname' } })
          user.reload
          expect(user.username).to eq('testname')
        end

        it 'can edit the email' do
          expect(user.email).to eq('user@localhost')
          post(:update, params: { api_key: api_key.key, id: user.id, user: { email: 'user2@localhost' } })
          user.reload
          expect(user.email).to eq('user2@localhost')
        end
      end
    end
  end
end
