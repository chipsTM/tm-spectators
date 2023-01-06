[Setting name="Show Specatators"]
bool show_spec = true;
[Setting name="Hide With Interface"]
bool hideWithInterface = true;
[Setting name="anchor_x"]
float anchor_x = 0.536;
[Setting name="anchor_y"]
float anchor_y = 0.91;
[Setting name="font_size" min=10 max=100]
int size = 24;

void RenderMenu() {
	if (UI::MenuItem(Icons::User + "\\$z Spec Counter", "", show_spec)) {
		show_spec = !show_spec;
	}
}

void Render() {
    auto app = cast<CTrackMania>(GetApp());
    auto network = cast<CTrackManiaNetwork>(app.Network);
    auto playground = cast<CSmArenaClient>(GetApp().CurrentPlayground);

    if (playground is null ||
        playground.GameTerminals.Length <= 0 ||
        playground.GameTerminals[0].UISequence_Current != CGamePlaygroundUIConfig::EUISequence::Playing) {
        return;
    }

    if (hideWithInterface && !UI::IsGameUIVisible()) {
		return;
	}

    uint numSpec = 0;
    array<string> directspec;
    array<string> spectators;
    if (network.PlayerInfos.Length > 0) {
        auto players = network.PlayerInfos;
        for (uint i = 0; i < players.Length; i++) {
            if (cast<CGamePlayerInfo>(players[i]).SpectatorMode == CGameNetPlayerInfo::ESpectatorMode::LocalWatcher) {
                directspec.InsertLast(cast<CGamePlayerInfo>(players[i]).Name);
            }
            if (cast<CGamePlayerInfo>(players[i]).SpectatorMode == CGameNetPlayerInfo::ESpectatorMode::Watcher) {
                spectators.InsertLast(cast<CGamePlayerInfo>(players[i]).Name);
            }
            if (cast<CGamePlayerInfo>(players[i]).Login == network.PlayerInfo.Login) {
                numSpec = cast<CGamePlayerInfo>(players[i]).NbSpectators;
            }
        }
    }
    if (show_spec && numSpec > 0) {
        nvg::FontSize(size);
        nvg::TextAlign(nvg::Align::Center | nvg::Align::Middle);
        string t = Icons::Eye + " " + numSpec;
        float g_w = anchor_x * Draw::GetWidth();
        float g_h = anchor_y * Draw::GetHeight();
        nvg::Text(g_w, g_h, t);
        vec2 mouse = UI::GetMousePos();
        vec2 bounds = nvg::TextBounds(t);
        if (mouse.x > g_w - bounds.x/2 && mouse.x <  g_w + bounds.x/2 && mouse.y > g_h - bounds.y/2 && mouse.y <  g_h + bounds.y/2) {
            for (uint w = 0; w < directspec.Length; w++) {
                nvg::Text(g_w + 2 * bounds.x, g_h - w * bounds.y, directspec[w]);
            }
        }
    }
}

void Main() { }