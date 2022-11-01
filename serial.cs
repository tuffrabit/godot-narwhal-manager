using Godot;
using System;
using System.IO.Ports;

public class serial : Node
{
	protected SerialPort port = null;
	
	public string[] getAvailablePortNames()
	{
		return SerialPort.GetPortNames();
	}
	
	public bool connectToPort(string portName)
	{
		bool connected = false;
		
		if (this.port != null && this.port.IsOpen)
		{
			this.port.Close();
		}
		
		this.port = new SerialPort(portName, 115200, Parity.None, 8, StopBits.One);
		this.port.DtrEnable = true;
		this.port.ReadTimeout = 1000;
		this.port.WriteTimeout = 1000;
		
		try
		{
			this.port.Open();
			connected = true;
		}
		catch
		{
			this.port = null;
		}
		
		return connected;
	}
	
	public void writeLine(string message)
	{
		if (this.port != null && this.port.IsOpen)
		{
			this.port.WriteLine(message);
		}
	}
	
	public string readLine()
	{
		string line = "";
		
		if (this.port != null && this.port.IsOpen)
		{
			try {
				line = this.port.ReadLine();
			}
			catch (System.TimeoutException e) { }
		}
		
		return line;
	}
}
