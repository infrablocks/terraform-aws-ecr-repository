require 'spec_helper'

describe 'S3 Bucket' do
  include_context :terraform

  let(:bucket_name_prefix) {RSpec.configuration.bucket_name_prefix}
  let(:region) {RSpec.configuration.region}
  let(:deployment_identifier) {RSpec.configuration.deployment_identifier}

  subject {
    s3_bucket("#{bucket_name_prefix}-#{region}-#{deployment_identifier}")
  }

  it {should exist}

  it 'has tags' do
    tags = s3_client.get_bucket_tagging({bucket: subject.name}).to_h

    expect(tags[:tag_set]).to(
        include({key: 'Component', value: 'common'}))
    expect(tags[:tag_set]).to(
        include({key: 'Name', value: subject.name}))
    expect(tags[:tag_set]).to(
        include({
                    key: 'DeploymentIdentifier',
                    value: deployment_identifier}))
  end
end