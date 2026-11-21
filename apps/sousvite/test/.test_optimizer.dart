// GENERATED CODE - DO NOT MODIFY BY HAND
// Consider adding this file to your .gitignore.

import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart' hide group;
import 'package:test_api/scaffolding.dart' show group;


import 'app/app_shell_test.dart' as _a;
import 'app/app_test.dart' as _b;
import 'app/providers/repositories_test.dart' as _c;
import 'app/router_test.dart' as _d;
import 'app/services/app_check_test.dart' as _e;
import 'app/services/error_reporter_test.dart' as _f;
import 'app/services/firebase_auth_service_test.dart' as _g;
import 'app/services/firebase_sharing_service_test.dart' as _h;
import 'app/services/firebase_test.dart' as _i;
import 'app/services/nutrition_api_test.dart' as _j;
import 'app/services/services_test.dart' as _k;
import 'app/services/sharing_service_test.dart' as _l;
import 'bootstrap_test.dart' as _m;
import 'features/account/application/account_controller_test.dart' as _n;
import 'features/account/presentation/account_screen_test.dart' as _o;
import 'features/account/sync/application/shared_spaces_test.dart' as _p;
import 'features/account/sync/application/sync_controller_test.dart' as _q;
import 'features/account/sync/application/sync_settings_test.dart' as _r;
import 'features/account/sync/data/cloud_firestore_space_test.dart' as _s;
import 'features/account/sync/data/drive_rest_folder_test.dart' as _t;
import 'features/account/sync/data/firebase_cloud_files_test.dart' as _u;
import 'features/account/sync/data/local_setting_test.dart' as _v;
import 'features/account/sync/data/space_memberships_test.dart' as _w;
import 'features/account/sync/presentation/sign_in_callout_card_test.dart' as _x;
import 'features/account/sync/presentation/sync_source_setting_test.dart' as _y;
import 'features/account/sync/presentation/sync_status_button_test.dart' as _z;
import 'features/cooking/application/cooking_application_test.dart' as _A;
import 'features/cooking/application/measuring_plan_test.dart' as _B;
import 'features/cooking/presentation/cooking_screen_test.dart' as _C;
import 'features/editor/application/editor_draft_test.dart' as _D;
import 'features/editor/presentation/editor_screen_test.dart' as _E;
import 'features/editor/presentation/recipe_photo_editor_test.dart' as _F;
import 'features/experiments/application/experiment_actions_test.dart' as _G;
import 'features/experiments/application/history_providers_test.dart' as _H;
import 'features/experiments/presentation/experiment_screen_test.dart' as _I;
import 'features/experiments/presentation/history_screen_test.dart' as _J;
import 'features/experiments/presentation/version_screen_test.dart' as _K;
import 'features/grocery/application/combine_grocery_items_test.dart' as _L;
import 'features/grocery/application/excluded_ingredients_test.dart' as _M;
import 'features/grocery/application/grocery_actions_test.dart' as _N;
import 'features/grocery/application/grocery_ids_test.dart' as _O;
import 'features/grocery/application/grocery_providers_test.dart' as _P;
import 'features/grocery/presentation/add_to_grocery_sheet_test.dart' as _Q;
import 'features/grocery/presentation/grocery_screen_test.dart' as _R;
import 'features/grocery/presentation/store_section_name_test.dart' as _S;
import 'features/import/application/recipe_url_test.dart' as _T;
import 'features/import/application/url_import_test.dart' as _U;
import 'features/import/data/library_umami_transfer_test.dart' as _V;
import 'features/import/data/page_fetchers_test.dart' as _W;
import 'features/import/data/page_url_importer_test.dart' as _X;
import 'features/import/presentation/import_screen_test.dart' as _Y;
import 'features/library/application/library_application_test.dart' as _Z;
import 'features/library/presentation/add_recipe_button_test.dart' as _aa;
import 'features/library/presentation/folder_screen_test.dart' as _ba;
import 'features/library/presentation/folder_tile_test.dart' as _ca;
import 'features/library/presentation/library_screen_test.dart' as _da;
import 'features/nutrition/application/auto_match_test.dart' as _ea;
import 'features/nutrition/application/nutrition_actions_test.dart' as _fa;
import 'features/nutrition/application/nutrition_basis_test.dart' as _ga;
import 'features/nutrition/application/nutrition_math_test.dart' as _ha;
import 'features/nutrition/application/nutrition_providers_test.dart' as _ia;
import 'features/nutrition/application/scanned_food_test.dart' as _ja;
import 'features/nutrition/presentation/barcode_camera_test.dart' as _ka;
import 'features/nutrition/presentation/match_library_tile_test.dart' as _la;
import 'features/nutrition/presentation/nutrition_screen_test.dart' as _ma;
import 'features/nutrition/presentation/nutrition_summary_test.dart' as _na;
import 'features/nutrition/presentation/scan_food_dialog_test.dart' as _oa;
import 'features/recipe/application/jarred_garlic_test.dart' as _pa;
import 'features/recipe/application/recipe_data_test.dart' as _qa;
import 'features/recipe/application/recipe_outline_test.dart' as _ra;
import 'features/recipe/application/recipe_scale_test.dart' as _sa;
import 'features/recipe/application/recipe_units_test.dart' as _ta;
import 'features/recipe/presentation/recipe_photo_test.dart' as _ua;
import 'features/recipe/presentation/recipe_screen_test.dart' as _va;
import 'features/recipe/presentation/smart_step_text_test.dart' as _wa;
import 'features/settings/application/jarred_garlic_controller_test.dart' as _xa;
import 'features/settings/application/measuring_tools_test.dart' as _ya;
import 'features/settings/application/theme_mode_controller_test.dart' as _za;
import 'features/settings/application/unit_system_controller_test.dart' as _Aa;
import 'features/settings/presentation/measuring_tools_screen_test.dart' as _Ba;
import 'features/settings/presentation/settings_screen_test.dart' as _Ca;
import 'features/sharing/application/recipe_sharing_test.dart' as _Da;
import 'features/sharing/application/shared_recipe_page_test.dart' as _Ea;
import 'features/sharing/presentation/invite_screen_test.dart' as _Fa;
import 'features/sharing/presentation/sharing_screen_test.dart' as _Ga;
import 'helpers/build_counter_test.dart' as _Ha;
import 'helpers/fakes/fake_recipe_repository_test.dart' as _Ia;
import 'shared/async/combine_async_test.dart' as _Ja;
import 'shared/format/duration_label_test.dart' as _Ka;
import 'shared/photos/file_photo_store_test.dart' as _La;
import 'shared/photos/photo_ref_test.dart' as _Ma;
import 'shared/photos/recipe_photos_test.dart' as _Na;
import 'shared/photos/shrink_photo_test.dart' as _Oa;
import 'shared/photos/stored_photo_image_test.dart' as _Pa;
import 'shared/widgets/async_value_view_test.dart' as _Qa;

void main() {
  goldenFileComparator = _TestOptimizationAwareGoldenFileComparator(goldenFileComparator as LocalFileComparator);
  group('app/app_shell_test.dart', () { _a.main(); });
  group('app/app_test.dart', () { _b.main(); });
  group('app/providers/repositories_test.dart', () { _c.main(); });
  group('app/router_test.dart', () { _d.main(); });
  group('app/services/app_check_test.dart', () { _e.main(); });
  group('app/services/error_reporter_test.dart', () { _f.main(); });
  group('app/services/firebase_auth_service_test.dart', () { _g.main(); });
  group('app/services/firebase_sharing_service_test.dart', () { _h.main(); });
  group('app/services/firebase_test.dart', () { _i.main(); });
  group('app/services/nutrition_api_test.dart', () { _j.main(); });
  group('app/services/services_test.dart', () { _k.main(); });
  group('app/services/sharing_service_test.dart', () { _l.main(); });
  group('bootstrap_test.dart', () { _m.main(); });
  group('features/account/application/account_controller_test.dart', () { _n.main(); });
  group('features/account/presentation/account_screen_test.dart', () { _o.main(); });
  group('features/account/sync/application/shared_spaces_test.dart', () { _p.main(); });
  group('features/account/sync/application/sync_controller_test.dart', () { _q.main(); });
  group('features/account/sync/application/sync_settings_test.dart', () { _r.main(); });
  group('features/account/sync/data/cloud_firestore_space_test.dart', () { _s.main(); });
  group('features/account/sync/data/drive_rest_folder_test.dart', () { _t.main(); });
  group('features/account/sync/data/firebase_cloud_files_test.dart', () { _u.main(); });
  group('features/account/sync/data/local_setting_test.dart', () { _v.main(); });
  group('features/account/sync/data/space_memberships_test.dart', () { _w.main(); });
  group('features/account/sync/presentation/sign_in_callout_card_test.dart', () { _x.main(); });
  group('features/account/sync/presentation/sync_source_setting_test.dart', () { _y.main(); });
  group('features/account/sync/presentation/sync_status_button_test.dart', () { _z.main(); });
  group('features/cooking/application/cooking_application_test.dart', () { _A.main(); });
  group('features/cooking/application/measuring_plan_test.dart', () { _B.main(); });
  group('features/cooking/presentation/cooking_screen_test.dart', () { _C.main(); });
  group('features/editor/application/editor_draft_test.dart', () { _D.main(); });
  group('features/editor/presentation/editor_screen_test.dart', () { _E.main(); });
  group('features/editor/presentation/recipe_photo_editor_test.dart', () { _F.main(); });
  group('features/experiments/application/experiment_actions_test.dart', () { _G.main(); });
  group('features/experiments/application/history_providers_test.dart', () { _H.main(); });
  group('features/experiments/presentation/experiment_screen_test.dart', () { _I.main(); });
  group('features/experiments/presentation/history_screen_test.dart', () { _J.main(); });
  group('features/experiments/presentation/version_screen_test.dart', () { _K.main(); });
  group('features/grocery/application/combine_grocery_items_test.dart', () { _L.main(); });
  group('features/grocery/application/excluded_ingredients_test.dart', () { _M.main(); });
  group('features/grocery/application/grocery_actions_test.dart', () { _N.main(); });
  group('features/grocery/application/grocery_ids_test.dart', () { _O.main(); });
  group('features/grocery/application/grocery_providers_test.dart', () { _P.main(); });
  group('features/grocery/presentation/add_to_grocery_sheet_test.dart', () { _Q.main(); });
  group('features/grocery/presentation/grocery_screen_test.dart', () { _R.main(); });
  group('features/grocery/presentation/store_section_name_test.dart', () { _S.main(); });
  group('features/import/application/recipe_url_test.dart', () { _T.main(); });
  group('features/import/application/url_import_test.dart', () { _U.main(); });
  group('features/import/data/library_umami_transfer_test.dart', () { _V.main(); });
  group('features/import/data/page_fetchers_test.dart', () { _W.main(); });
  group('features/import/data/page_url_importer_test.dart', () { _X.main(); });
  group('features/import/presentation/import_screen_test.dart', () { _Y.main(); });
  group('features/library/application/library_application_test.dart', () { _Z.main(); });
  group('features/library/presentation/add_recipe_button_test.dart', () { _aa.main(); });
  group('features/library/presentation/folder_screen_test.dart', () { _ba.main(); });
  group('features/library/presentation/folder_tile_test.dart', () { _ca.main(); });
  group('features/library/presentation/library_screen_test.dart', () { _da.main(); });
  group('features/nutrition/application/auto_match_test.dart', () { _ea.main(); });
  group('features/nutrition/application/nutrition_actions_test.dart', () { _fa.main(); });
  group('features/nutrition/application/nutrition_basis_test.dart', () { _ga.main(); });
  group('features/nutrition/application/nutrition_math_test.dart', () { _ha.main(); });
  group('features/nutrition/application/nutrition_providers_test.dart', () { _ia.main(); });
  group('features/nutrition/application/scanned_food_test.dart', () { _ja.main(); });
  group('features/nutrition/presentation/barcode_camera_test.dart', () { _ka.main(); });
  group('features/nutrition/presentation/match_library_tile_test.dart', () { _la.main(); });
  group('features/nutrition/presentation/nutrition_screen_test.dart', () { _ma.main(); });
  group('features/nutrition/presentation/nutrition_summary_test.dart', () { _na.main(); });
  group('features/nutrition/presentation/scan_food_dialog_test.dart', () { _oa.main(); });
  group('features/recipe/application/jarred_garlic_test.dart', () { _pa.main(); });
  group('features/recipe/application/recipe_data_test.dart', () { _qa.main(); });
  group('features/recipe/application/recipe_outline_test.dart', () { _ra.main(); });
  group('features/recipe/application/recipe_scale_test.dart', () { _sa.main(); });
  group('features/recipe/application/recipe_units_test.dart', () { _ta.main(); });
  group('features/recipe/presentation/recipe_photo_test.dart', () { _ua.main(); });
  group('features/recipe/presentation/recipe_screen_test.dart', () { _va.main(); });
  group('features/recipe/presentation/smart_step_text_test.dart', () { _wa.main(); });
  group('features/settings/application/jarred_garlic_controller_test.dart', () { _xa.main(); });
  group('features/settings/application/measuring_tools_test.dart', () { _ya.main(); });
  group('features/settings/application/theme_mode_controller_test.dart', () { _za.main(); });
  group('features/settings/application/unit_system_controller_test.dart', () { _Aa.main(); });
  group('features/settings/presentation/measuring_tools_screen_test.dart', () { _Ba.main(); });
  group('features/settings/presentation/settings_screen_test.dart', () { _Ca.main(); });
  group('features/sharing/application/recipe_sharing_test.dart', () { _Da.main(); });
  group('features/sharing/application/shared_recipe_page_test.dart', () { _Ea.main(); });
  group('features/sharing/presentation/invite_screen_test.dart', () { _Fa.main(); });
  group('features/sharing/presentation/sharing_screen_test.dart', () { _Ga.main(); });
  group('helpers/build_counter_test.dart', () { _Ha.main(); });
  group('helpers/fakes/fake_recipe_repository_test.dart', () { _Ia.main(); });
  group('shared/async/combine_async_test.dart', () { _Ja.main(); });
  group('shared/format/duration_label_test.dart', () { _Ka.main(); });
  group('shared/photos/file_photo_store_test.dart', () { _La.main(); });
  group('shared/photos/photo_ref_test.dart', () { _Ma.main(); });
  group('shared/photos/recipe_photos_test.dart', () { _Na.main(); });
  group('shared/photos/shrink_photo_test.dart', () { _Oa.main(); });
  group('shared/photos/stored_photo_image_test.dart', () { _Pa.main(); });
  group('shared/widgets/async_value_view_test.dart', () { _Qa.main(); });
}


class _TestOptimizationAwareGoldenFileComparator extends GoldenFileComparator {
  final List<String> goldenFilePaths;
  final LocalFileComparator previousGoldenFileComparator;

  _TestOptimizationAwareGoldenFileComparator(this.previousGoldenFileComparator)
      : goldenFilePaths = _goldenFilePaths;

  static List<String> get _goldenFilePaths =>
      Directory.fromUri((goldenFileComparator as LocalFileComparator).basedir)
          .listSync(recursive: true, followLinks: true)
          .whereType<File>()
          .map((file) => file.path)
          .where((path) => path.endsWith('.png'))
          .toList();
  @override
  Future<bool> compare(Uint8List imageBytes, Uri golden)  => previousGoldenFileComparator.compare(imageBytes, golden);

  @override
  Uri getTestUri(Uri key, int? version) {
    final keyString = key.toFilePath();
    return Uri.parse(goldenFilePaths
        .singleWhere((goldenFilePath) => goldenFilePath.endsWith(keyString)));
  }

  @override
  Future<void> update(Uri golden, Uint8List imageBytes) => previousGoldenFileComparator.update(golden, imageBytes);

}
