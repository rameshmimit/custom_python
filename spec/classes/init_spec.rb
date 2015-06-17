require 'spec_helper'
describe 'python' do

  context 'with defaults for all parameters' do
    it { should contain_class('python') }
  end
end
