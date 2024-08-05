using System.Net;
using System.Net.Sockets;
using System.Text.Json.Serialization;
using System.Text.RegularExpressions;

var builder = WebApplication.CreateSlimBuilder(args);

builder.Services.ConfigureHttpJsonOptions(options =>
{
options.SerializerOptions.TypeInfoResolverChain.Insert(0, AppJsonSerializerContext.Default);
});

var app = builder.Build();
var errorMessage = "Please provide a valid MAC: http://{address}:12563/wol/00-00-00-00-00-00";

app.MapGet("/", () => errorMessage);
app.MapGet("/wol/", () => errorMessage);
app.MapGet("/wol/{mac}", (string mac) =>
{
    // check if it's a valid MAC address
    if (!Regex.IsMatch(mac, "^([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})$")
        || mac == "00-00-00-00-00-00")
        return Results.BadRequest("Invalid MAC address");
    WOL.SendMagicPackage(mac.Replace("-", ":"));
    return Results.Ok("Magic packet sent");
});

app.Run();

[JsonSerializable(typeof(string))]
internal partial class AppJsonSerializerContext : JsonSerializerContext
{

}

internal static class WOL
{
    internal static void SendMagicPackage(string macAddress)
    {
        var macBytes = macAddress.Split(':').Select(s => Convert.ToByte(s, 16)).ToArray();
        var magicPacket = new byte[102];
        for (int i = 0; i < 6; i++)
            magicPacket[i] = 0xFF;
        for (int i = 6; i < 102; i += 6)
            Buffer.BlockCopy(macBytes, 0, magicPacket, i, 6);
        using var client = new UdpClient();
        client.Connect(IPAddress.Broadcast, 9);
        client.Send(magicPacket, magicPacket.Length);
        client.Close();
    }
}