#define Server_Bind_IP "87.98.243.201"
#define Save_Ersteller "HandyCap"
public OnGameModeInit()
{
   	new Server_Bind_Str[500];
	GetServerVarAsString("bind",Server_Bind_Str,sizeof(Server_Bind_Str));
	if(!Server_Bind_Str[0] || strcmp(Server_Bind_Str,Server_Bind_IP,false))
	{
		print("ERROR CODE: 778AB");
		print("ERROR CODE: 778AB");
		print("ERROR CODE: 778AB");
		print("ERROR CODE: 778AB");
	    	print("ERROR CODE: 778AB");
	    	print("ERROR CODE: 778AB");
	    	print("ERROR CODE: 778AB");
	    	print("ERROR CODE: 778AB");
	    	print("ERROR CODE: 778AB");
	    	print("ERROR CODE: 778AB");
        	print("Bitte sagen sie sofort ("Save_Ersteller") bescheid!");
		SendRconCommand("exit");
	 	return 1;
	}
	return 1;
}