require "spec_helper"

describe file("/opt/snap/bin/snapd") do
  it { should exist }
end

describe file("/opt/snap/bin/snapctl") do
  it { should exist }
end

describe command("/opt/snap/bin/snapd help") do
  its(:stdout) { should match /snapd - The open telemetry framework/ }
end

describe command("/opt/snap/bin/snapctl") do
  its(:stdout) { should match /snapctl - The open telemetry framework/ }
end

case os[:family]
when 'darwin'
  describe package("com.intel.pkg.snap-telemetry") do
    it { should be_installed.by("pkgutil") }
  end

  describe file("/usr/local/bin/snapd") do
    it { should be_symlink }
  end

  describe file("/usr/local/bin/snapctl") do
    it { should be_symlink }
  end
else
  describe package("snap-telemetry") do
    it { should be_installed }
  end

  describe file("/usr/bin/snapd") do
    it { should be_symlink }
  end

  describe file("/usr/bin/snapctl") do
    it { should be_symlink }
  end

  describe command("ldd $(which snapd)") do
    its(:stdout) { should match /not a dynamic executable/ }
  end

  describe service("snap-telemetry") do
    it { should be_enabled }
    it { should be_running }
  end

  describe port(8181) do
    it { should be_listening }
  end

  describe file("/var/log/snap/snapd.log") do
    it { should exist }
  end
end
