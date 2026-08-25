#include </Gloabe Includes/a_npc>
main(){}
#define RECORDING "[BOT]Stadthalle1"

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
