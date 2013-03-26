require 'spec_helper'

describe Ridley::Connector do
  
  subject do
    described_class
  end

  it "returns 22 as the default SSH port" do
    described_class::DEFAULT_SSH_PORT.should eq(22)
  end

  it "returns 5985 as the default WinRM port" do
    described_class::DEFAULT_WINRM_PORT.should eq(5985)
  end

  describe "#default_connector_port_open" do
    let(:host) {"127.0.0.1"}
    let(:port) {22}
    let(:socket) {double(:new => true, :close => nil)}

    context "when a port is open" do
      it "returns true" do
        TCPSocket.stub(:new).and_return(socket)
        subject.default_connector_port_open?(host, port).should eq(true)
      end
    end

    context "when a port is closed" do
      it "returns false" do
        TCPSocket.stub(:new).and_raise(Errno::ECONNREFUSED)
        subject.default_connector_port_open?(host, port).should eq(false)
      end
    end
  end

  describe "#best_connector_for" do
    let(:host) {"127.0.0.1"}
    
    context "when an SSH port is open" do
      it "returns Ridley::Connector::SSH" do
        subject.stub(:default_connector_port_open?).and_return(true)
        subject.best_connector_for(host).should eq(Ridley::Connector::SSH)
      end
    end

    context "when an SSH port isnt open and a WinRM port is open" do
      it "returns Ridley::Connector::WinRM" do
        subject.stub(:default_connector_port_open?).and_return(false, true)
        subject.best_connector_for(host).should eq(Ridley::Connector::WinRM)
      end
    end

    context "when no useable ports are open" do
      it "raises an exception" do
        subject.stub(:default_connector_port_open?).and_return(false, false)
        expect {
          subject.best_connector_for(host)
        }.to raise_error(Ridley::Errors::UnknownConnector)
      end
    end
  end
end
