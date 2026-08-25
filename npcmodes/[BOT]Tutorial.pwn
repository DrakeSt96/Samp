#include <a_npc>
main(){}
#define RECORDING "[BOT]Tutorial"

#define RECORDING_TYPE 2

public OnRecordingPlaybackEnd()
StartRecordingPlayback(RECORDING_TYPE, RECORDING);

public OnNPCEnterVehicle(vehicleid, seatid)
StartRecordingPlayback(RECORDING_TYPE, RECORDING);

public OnNPCExitVehicle()
StopRecordingPlayback();

public OnNPCSpawn()
{
StartRecordingPlayback(RECORDING_TYPE, RECORDING);
}
