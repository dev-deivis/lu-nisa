# Graph Report - lunisa  (2026-05-02)

## Corpus Check
- 55 files · ~78,265 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 349 nodes · 367 edges · 22 communities detected
- Extraction: 98% EXTRACTED · 2% INFERRED · 0% AMBIGUOUS · INFERRED: 8 edges (avg confidence: 0.8)
- Token cost: 0 input · 0 output

## Community Hubs (Navigation)
- [[_COMMUNITY_Community 0|Community 0]]
- [[_COMMUNITY_Community 1|Community 1]]
- [[_COMMUNITY_Community 2|Community 2]]
- [[_COMMUNITY_Community 3|Community 3]]
- [[_COMMUNITY_Community 4|Community 4]]
- [[_COMMUNITY_Community 5|Community 5]]
- [[_COMMUNITY_Community 6|Community 6]]
- [[_COMMUNITY_Community 7|Community 7]]
- [[_COMMUNITY_Community 8|Community 8]]
- [[_COMMUNITY_Community 9|Community 9]]
- [[_COMMUNITY_Community 10|Community 10]]
- [[_COMMUNITY_Community 11|Community 11]]
- [[_COMMUNITY_Community 12|Community 12]]
- [[_COMMUNITY_Community 13|Community 13]]
- [[_COMMUNITY_Community 14|Community 14]]
- [[_COMMUNITY_Community 15|Community 15]]
- [[_COMMUNITY_Community 16|Community 16]]
- [[_COMMUNITY_Community 17|Community 17]]
- [[_COMMUNITY_Community 18|Community 18]]
- [[_COMMUNITY_Community 19|Community 19]]
- [[_COMMUNITY_Community 20|Community 20]]
- [[_COMMUNITY_Community 21|Community 21]]

## God Nodes (most connected - your core abstractions)
1. `package:flutter/material.dart` - 12 edges
2. `package:go_router/go_router.dart` - 11 edges
3. `package:provider/provider.dart` - 9 edges
4. `AppDelegate` - 8 edges
5. `../../core/providers/app_provider.dart` - 8 edges
6. `Create()` - 6 edges
7. `Destroy()` - 6 edges
8. `MessageHandler()` - 5 edges
9. `OnCreate()` - 4 edges
10. `WndProc()` - 4 edges

## Surprising Connections (you probably didn't know these)
- `OnCreate()` --calls--> `RegisterPlugins()`  [INFERRED]
  windows/runner/flutter_window.cpp → windows/flutter/generated_plugin_registrant.cc
- `wWinMain()` --calls--> `CreateAndAttachConsole()`  [INFERRED]
  windows/runner/main.cpp → windows/runner/utils.cpp
- `wWinMain()` --calls--> `GetCommandLineArguments()`  [INFERRED]
  windows/runner/main.cpp → windows/runner/utils.cpp
- `OnCreate()` --calls--> `GetClientArea()`  [INFERRED]
  windows/runner/flutter_window.cpp → windows/runner/win32_window.cpp
- `OnCreate()` --calls--> `SetChildContent()`  [INFERRED]
  windows/runner/flutter_window.cpp → windows/runner/win32_window.cpp

## Communities

### Community 0 - "Community 0"
Cohesion: 0.05
Nodes (41): AppBar, _BadgeParcela, _BadgeRazon, _BannerSinFoto, _BentoGrid, _BotonesAccion, build, Center (+33 more)

### Community 1 - "Community 1"
Cohesion: 0.11
Nodes (19): RegisterPlugins(), FlutterWindow(), OnCreate(), Create(), Destroy(), EnableFullDpiSupportIfAvailable(), GetClientArea(), GetThisFromHandle() (+11 more)

### Community 2 - "Community 2"
Cohesion: 0.07
Nodes (24): dart:convert, dart:io, dart:ui, ../../data/models/cultivo_recomendado.dart, ../../data/repositories/recomendacion_repository.dart, agregarConsulta, AppProvider, Consulta (+16 more)

### Community 3 - "Community 3"
Cohesion: 0.08
Nodes (22): AppBar, build, Container, Divider, Expanded, Icon, _LunisaAppBar, Padding (+14 more)

### Community 4 - "Community 4"
Cohesion: 0.08
Nodes (23): _AnalizarButton, build, _CargandoClima, _ClimaDetalle, _ClimaInfo, Color, Column, Container (+15 more)

### Community 5 - "Community 5"
Cohesion: 0.09
Nodes (22): ../../core/data/municipios_data.dart, _BarraBusqueda, build, Center, Column, _ContadorResultados, Container, dispose (+14 more)

### Community 6 - "Community 6"
Cohesion: 0.09
Nodes (21): ../../core/services/location_service.dart, ../data/municipios_data.dart, estaDentroSierraNorte, LocationService, build, Center, _confirmarMunicipio, initState (+13 more)

### Community 7 - "Community 7"
Cohesion: 0.09
Nodes (22): _AreaFoto, _BotonAccion, build, CamaraScreen, _CamaraScreenState, _CheckItem, Container, dispose (+14 more)

### Community 8 - "Community 8"
Cohesion: 0.09
Nodes (22): AppBar, _bgIconCultivo, build, Center, _ChipFiltro, _ContenidoHistorial, CustomScrollView, _emojiCultivo (+14 more)

### Community 9 - "Community 9"
Cohesion: 0.1
Nodes (17): AppTheme, TextStyle, build, Container, GestureDetector, LunisaBottomNav, _NavItem, SizedBox (+9 more)

### Community 10 - "Community 10"
Cohesion: 0.12
Nodes (15): ../../core/providers/app_provider.dart, ../../core/theme/app_theme.dart, features/camara/camara_screen.dart, features/historial/historial_screen.dart, features/inicio/inicio_screen.dart, features/main_screen.dart, features/municipio/municipio_screen.dart, features/onboarding/onboarding_screen.dart (+7 more)

### Community 11 - "Community 11"
Cohesion: 0.14
Nodes (4): fl_register_plugins(), main(), my_application_activate(), my_application_new()

### Community 12 - "Community 12"
Cohesion: 0.22
Nodes (3): FlutterAppDelegate, FlutterImplicitEngineDelegate, AppDelegate

### Community 13 - "Community 13"
Cohesion: 0.47
Nodes (4): wWinMain(), CreateAndAttachConsole(), GetCommandLineArguments(), Utf8FromUtf16()

### Community 14 - "Community 14"
Cohesion: 0.33
Nodes (3): RegisterGeneratedPlugins(), NSWindow, MainFlutterWindow

### Community 15 - "Community 15"
Cohesion: 0.4
Nodes (2): RunnerTests, XCTestCase

### Community 16 - "Community 16"
Cohesion: 0.5
Nodes (2): handle_new_rx_page(), Intercept NOTIFY_DEBUGGER_ABOUT_RX_PAGES and touch the pages.

### Community 17 - "Community 17"
Cohesion: 0.67
Nodes (2): ClimaMes, CultivoRecomendado

### Community 18 - "Community 18"
Cohesion: 0.67
Nodes (2): GeneratedPluginRegistrant, -registerWithRegistry

### Community 19 - "Community 19"
Cohesion: 0.67
Nodes (2): FlutterSceneDelegate, SceneDelegate

### Community 20 - "Community 20"
Cohesion: 0.67
Nodes (1): GeneratedPluginRegistrant

### Community 21 - "Community 21"
Cohesion: 1.0
Nodes (1): MainActivity

## Knowledge Gaps
- **224 isolated node(s):** `main`, `package:flutter_test/flutter_test.dart`, `package:lunisa/main.dart`, `package:lunisa/core/providers/app_provider.dart`, `Intercept NOTIFY_DEBUGGER_ABOUT_RX_PAGES and touch the pages.` (+219 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **Thin community `Community 15`** (5 nodes): `RunnerTests.swift`, `RunnerTests.swift`, `RunnerTests`, `.testExample()`, `XCTestCase`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 16`** (4 nodes): `handle_new_rx_page()`, `__lldb_init_module()`, `Intercept NOTIFY_DEBUGGER_ABOUT_RX_PAGES and touch the pages.`, `flutter_lldb_helper.py`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 17`** (3 nodes): `ClimaMes`, `CultivoRecomendado`, `cultivo_recomendado.dart`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 18`** (3 nodes): `GeneratedPluginRegistrant.m`, `GeneratedPluginRegistrant`, `-registerWithRegistry`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 19`** (3 nodes): `FlutterSceneDelegate`, `SceneDelegate.swift`, `SceneDelegate`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 20`** (3 nodes): `GeneratedPluginRegistrant.java`, `GeneratedPluginRegistrant`, `.registerWith()`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 21`** (2 nodes): `MainActivity.kt`, `MainActivity`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `package:flutter/material.dart` connect `Community 9` to `Community 0`, `Community 3`, `Community 4`, `Community 5`, `Community 6`, `Community 7`, `Community 8`, `Community 10`?**
  _High betweenness centrality (0.119) - this node is a cross-community bridge._
- **Why does `package:go_router/go_router.dart` connect `Community 9` to `Community 0`, `Community 3`, `Community 4`, `Community 5`, `Community 6`, `Community 7`, `Community 8`, `Community 10`?**
  _High betweenness centrality (0.107) - this node is a cross-community bridge._
- **Why does `package:provider/provider.dart` connect `Community 3` to `Community 0`, `Community 4`, `Community 5`, `Community 6`, `Community 7`, `Community 8`, `Community 10`?**
  _High betweenness centrality (0.097) - this node is a cross-community bridge._
- **What connects `main`, `package:flutter_test/flutter_test.dart`, `package:lunisa/main.dart` to the rest of the system?**
  _224 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Community 0` be split into smaller, more focused modules?**
  _Cohesion score 0.05 - nodes in this community are weakly interconnected._
- **Should `Community 1` be split into smaller, more focused modules?**
  _Cohesion score 0.11 - nodes in this community are weakly interconnected._
- **Should `Community 2` be split into smaller, more focused modules?**
  _Cohesion score 0.07 - nodes in this community are weakly interconnected._