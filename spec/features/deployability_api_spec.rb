# frozen_string_literal: true

require "rails_helper"
require "exceptions_test_helper"

RSpec.feature "an API to know whether a project is a deployable", type: :request do
  include ExceptionsTestHelper

  describe "GET /api/projects/:id/deployability" do
    context "when we do not pass any resolved parameter" do
      it "does not filter by resolved, but still filters by project id" do
        artsy = Organization.create!(name: "Artsy")
        shipping = artsy.projects.create!(name: "shipping")
        packing = artsy.projects.create!(name: "packing")
        unresolved_shipping_deploy_block = DeployBlock.create!(project: shipping)
        resolved_shipping_deploy_block = DeployBlock.create!(
          project: shipping,
          resolved_at: DateTime.current
        )
        DeployBlock.create(project: packing)
        DeployBlock.create(
          project: packing,
          resolved_at: DateTime.now
        )

        headers = {"ACCEPT" => "application/json"}
        get "/api/deploy_blocks?project_id=#{shipping.id}", headers: headers
        expect(response.body).to eq(
          [unresolved_shipping_deploy_block, resolved_shipping_deploy_block].to_json
        )
      end
    end
    context "when querying for resolved deploy blocks" do
      it "only returns resolved, not unresolved, for the given project" do
        artsy = Organization.create!(name: "Artsy")
        shipping = artsy.projects.create!(name: "shipping")
        packing = artsy.projects.create!(name: "packing")
        DeployBlock.create!(project: shipping)
        resolved_shipping_deploy_block = DeployBlock.create!(
          project: shipping,
          resolved_at: DateTime.current
        )
        DeployBlock.create(project: packing)
        DeployBlock.create(
          project: packing,
          resolved_at: DateTime.now
        )

        headers = {"ACCEPT" => "application/json"}
        get "/api/deploy_blocks?project_id=#{shipping.id}&resolved=true", headers: headers

        expect(response.body).to eq([resolved_shipping_deploy_block].to_json)
      end
    end

    context "when querying for unresolved deploy blocks" do
      it "returns 200 SUCCESS and an empty response if there are no unresolved blocks" do
        artsy = Organization.create!(name: "Artsy")
        shipping = artsy.projects.create!(name: "shipping")

        headers = {"ACCEPT" => "application/json"}
        get "/api/deploy_blocks?project_id=#{shipping.id}&resolved=false", headers: headers

        expect(response).to have_http_status(:success)
        expect(response.body).to eq("[]")
      end

      it "enforces basic auth on deploy_blocks API" do
        allow(Horizon).to receive(:config).and_return(
          basic_auth_user: "admin",
          basic_auth_pass: "secret"
        )
        artsy = Organization.create!(name: "Artsy")
        shipping = artsy.projects.create!(name: "shipping")
        headers = {"ACCEPT" => "application/json"}
        get "/api/deploy_blocks?project_id=#{shipping.id}&resolved=false", headers: headers
        expect(response).to have_http_status(:unauthorized)

        get "/api/deploy_blocks?project_id=#{shipping.id}&resolved=false", headers: headers.merge(
          "Authorization" => ActionController::HttpAuthentication::Basic.encode_credentials("admin", "secret")
        )
        expect(response).to have_http_status(:success)
        expect(response.body).to eq("[]")
      end

      context "with unresolved deploy blocks" do
        it "returns 200 SUCCESS and the deploy block in the response" do
          artsy = Organization.create!(name: "Artsy")
          shipping = artsy.projects.create!(name: "shipping")
          shipping_deploy_block = DeployBlock.create!(project: shipping)

          headers = {"ACCEPT" => "application/json"}
          get "/api/deploy_blocks?project_id=#{shipping.id}&resolved=false", headers: headers

          expect(response.body).to eq([shipping_deploy_block].to_json)
        end

        it "only returns deploy blocks for the project" do
          artsy = Organization.create!(name: "Artsy")
          shipping = artsy.projects.create!(name: "shipping")
          packing = artsy.projects.create!(name: "packing")
          shipping_deploy_block = DeployBlock.create!(project: shipping)
          DeployBlock.create!(project: packing)

          headers = {"ACCEPT" => "application/json"}
          get "/api/deploy_blocks?project_id=#{shipping.id}&resolved=false", headers: headers

          expect(response.body).to eq([shipping_deploy_block].to_json)
        end
      end

      context "with unresolved deploy blocks based on future release timespan" do
        it "returns 200 SUCCESS and the deploy block in the response" do
          artsy = Organization.create!(name: "Artsy")
          shipping = artsy.projects.create!(name: "shipping")
          shipping_deploy_block = DeployBlock.create!(project: shipping, resolved_at: DateTime.current + 10.days)

          headers = {"ACCEPT" => "application/json"}
          get "/api/deploy_blocks?project_id=#{shipping.id}&resolved=false", headers: headers

          expect(response.body).to eq([shipping_deploy_block].to_json)
        end

        it "only returns deploy blocks for the project" do
          artsy = Organization.create!(name: "Artsy")
          shipping = artsy.projects.create!(name: "shipping")
          packing = artsy.projects.create!(name: "packing")
          shipping_deploy_block = DeployBlock.create!(project: shipping)
          DeployBlock.create!(project: packing)

          headers = {"ACCEPT" => "application/json"}
          get "/api/deploy_blocks?project_id=#{shipping.id}&resolved=false", headers: headers

          expect(response.body).to eq([shipping_deploy_block].to_json)
        end
      end

      context "with resolved deploy blocks" do
        it "only returns the unresolved deploy blocks, and not resolved ones" do
          artsy = Organization.create!(name: "Artsy")
          shipping = artsy.projects.create!(name: "shipping")
          artsy.projects.create!(name: "packing")
          unresolved_deploy_block = DeployBlock.create!(project: shipping)
          DeployBlock.create!(
            project: shipping,
            resolved_at: DateTime.current
          )

          headers = {"ACCEPT" => "application/json"}
          get "/api/deploy_blocks?project_id=#{shipping.id}&resolved=false", headers: headers

          expect(JSON.parse(response.body).count).to eq(1)

          expect(
            JSON.parse(response.body).map { |payload| payload["id"] }
          ).to eq([unresolved_deploy_block.id])
        end
      end
    end

    it "returns a 404 if requesting for a project that does not exist" do
      with_exceptions_app do
        headers = {"ACCEPT" => "application/json"}
        get "/api/deploy_blocks?project_id=-2&resolved=false", headers: headers
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
