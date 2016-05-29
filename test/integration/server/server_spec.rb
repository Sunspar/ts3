describe service('ts3-server') do
  it { should be_installed }
  it { should be_enabled }
  it { should be_running }
end

describe port(9987) do
  it { should be_listening }
  its('protocols') { should eq ['udp'] }
end
