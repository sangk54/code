//================================================================================
//
//
//
//================================================================================


package Asst3b;


import java.rmi.Remote;
import java.rmi.RemoteException;


//--------------------------------------------------------------------------------
//
public interface	EcoRemoteReceiver	extends Remote
{
	public void	accept( EcoEvent t )	throws RemoteException;
}
