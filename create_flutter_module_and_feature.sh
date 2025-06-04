#!/bin/bash

# --- Script to Scaffold Flutter Module and Initial Feature Structure ---

# Function to convert snake_case to PascalCase (e.g., my_input_name -> MyInputName)
snake_to_pascal_case() {
  echo "$1" | awk -F_ '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) substr($i,2); print}' OFS=""
}

# Function to convert PascalCase to camelCase (e.g., MyInputName -> myInputName)
pascal_to_camel_case() {
  local pascal_string="$1"
  local first_char_lower=$(echo "${pascal_string:0:1}" | tr '[:upper:]' '[:lower:]')
  local rest_of_string="${pascal_string:1}"
  echo "${first_char_lower}${rest_of_string}"
}

# --- Stage 1: Module Creation ---

# 1. Ask for the Module name
echo "Enter the name for the new Flutter Module (package, snake_case, e.g., auth_service):"
read MODULE_NAME_SNAKE

if [ -z "$MODULE_NAME_SNAKE" ]; then
  echo "Error: Module name cannot be empty."
  exit 1
fi

# Check if module directory already exists in the current path
if [ -d "$MODULE_NAME_SNAKE" ]; then
  echo "Error: A directory named '$MODULE_NAME_SNAKE' already exists here."
  echo "Please remove it, choose a different name, or navigate to a different parent directory."
  exit 1
fi

# Create the Flutter package (module)
echo "Creating Flutter package (module): $MODULE_NAME_SNAKE..."
flutter create --template=package "$MODULE_NAME_SNAKE"

# Check if flutter create was successful
if [ ! -d "$MODULE_NAME_SNAKE" ] || [ ! -f "$MODULE_NAME_SNAKE/pubspec.yaml" ]; then
  echo "Error: Failed to create module '$MODULE_NAME_SNAKE'."
  echo "Please check your Flutter setup and ensure the module name is valid."
  exit 1
fi
echo "Module '$MODULE_NAME_SNAKE' created successfully."
echo ""

# Navigate into the newly created module directory
echo "Changing directory to '$MODULE_NAME_SNAKE'..."
cd "$MODULE_NAME_SNAKE"
if [ $? -ne 0 ]; then
    echo "Error: Failed to change directory to '$MODULE_NAME_SNAKE'."
    exit 1
fi
echo "Now operating inside module: $PWD"
echo ""

# --- Stage 2: Feature Scaffolding within the Module ---

# Derive PascalCase and camelCase for Module Name
MODULE_NAME_PASCAL=$(snake_to_pascal_case "$MODULE_NAME_SNAKE")
MODULE_NAME_CAMEL=$(pascal_to_camel_case "$MODULE_NAME_PASCAL")

# 2. Ask for the Feature name
echo "Enter the specific FEATURE name for the initial feature within '$MODULE_NAME_SNAKE' (e.g., user_login, product_details):"
read FEATURE_NAME_SNAKE

if [ -z "$FEATURE_NAME_SNAKE" ]; then
  echo "Error: Feature name cannot be empty."
  # Optional: could cd .. back out of the module directory before exiting
  exit 1
fi
FEATURE_NAME_PASCAL=$(snake_to_pascal_case "$FEATURE_NAME_SNAKE")
FEATURE_NAME_CAMEL=$(pascal_to_camel_case "$FEATURE_NAME_PASCAL")

# Define the base path for feature scaffolding (inside the module's lib folder)
BASE_PATH="./lib" # This is now relative to the [MODULE_NAME_SNAKE] directory

# The 'lib' directory is created by 'flutter create --template=package'.
# We can add a check for robustness.
if [ ! -d "$BASE_PATH" ]; then
  echo "Error: '$BASE_PATH' directory not found inside '$PWD'. This should have been created by Flutter."
  # Optional: cd ..
  exit 1
fi

echo ""
echo "--- Configuration for Feature Scaffolding ---"
echo "Operating in Module: $MODULE_NAME_SNAKE (at $PWD)"
echo "Module Name (PascalCase): $MODULE_NAME_PASCAL"
echo "Module Name (camelCase): $MODULE_NAME_CAMEL"
echo "Feature Name (snake_case): $FEATURE_NAME_SNAKE"
echo "Feature Name (PascalCase): $FEATURE_NAME_PASCAL"
echo "Feature Name (camelCase): $FEATURE_NAME_CAMEL"
echo "Target Path for Scaffolding: $BASE_PATH"
echo "-------------------------------------------"
echo "Scaffolding feature structure in '$BASE_PATH'..."
echo ""

# --- Define Paths and Filenames for Feature Scaffolding ---

# Top-Level lib files (Module-based, but router might relate to feature)
FILE_LIB_MODULE_MAIN="$BASE_PATH/${MODULE_NAME_SNAKE}.dart" # This will overwrite the default one
FILE_LIB_MODULE_ROUTER="$BASE_PATH/${MODULE_NAME_SNAKE}_screen_router.dart"

# Data layer paths
DATA_PATH="$BASE_PATH/data"
DATA_MODULE_REPO_PATH="$DATA_PATH/${MODULE_NAME_SNAKE}_repository"
FILE_DATA_MODULE_REPO_IMPL="$DATA_MODULE_REPO_PATH/${MODULE_NAME_SNAKE}_repository_impl.dart"

DATA_MODELS_STATIC_PATH="$DATA_PATH/models"
DATA_MODELS_FEATURE_PATH="$DATA_MODELS_STATIC_PATH/${FEATURE_NAME_SNAKE}"
FILE_DATA_FEATURE_REQUEST="$DATA_MODELS_FEATURE_PATH/${FEATURE_NAME_SNAKE}_request.dart"
FILE_DATA_FEATURE_REQUEST_MODEL="$DATA_MODELS_FEATURE_PATH/${FEATURE_NAME_SNAKE}_request_model.dart"
FILE_DATA_FEATURE_RESPONSE_MODEL="$DATA_MODELS_FEATURE_PATH/${FEATURE_NAME_SNAKE}_response_model.dart"

DATA_REMOTE_PATH="$DATA_PATH/remote_data_source"
FILE_DATA_MODULE_REMOTE_SOURCE="$DATA_REMOTE_PATH/${MODULE_NAME_SNAKE}_remote_data_source.dart"

# DI layer paths (Module-based)
DI_PATH="$BASE_PATH/di"
FILE_DI_MODULE_MAIN="$DI_PATH/${MODULE_NAME_SNAKE}_di.dart"

# Domain layer paths
DOMAIN_PATH="$BASE_PATH/domain"
DOMAIN_MODULE_REPO_PATH="$DOMAIN_PATH/${MODULE_NAME_SNAKE}_repository"
FILE_DOMAIN_MODULE_REPO="$DOMAIN_MODULE_REPO_PATH/${MODULE_NAME_SNAKE}_repository.dart"

DOMAIN_MODULE_USECASE_BASE_PATH="$DOMAIN_PATH/${MODULE_NAME_SNAKE}_usecase"
DOMAIN_FEATURE_USECASE_PATH="$DOMAIN_MODULE_USECASE_BASE_PATH/${FEATURE_NAME_SNAKE}_usecase"
FILE_DOMAIN_FEATURE_USECASE="$DOMAIN_FEATURE_USECASE_PATH/${FEATURE_NAME_SNAKE}_usecase.dart"

# Presentation layer paths
PRESENTATION_PATH="$BASE_PATH/presentation"
PRES_UI_PATH="$PRESENTATION_PATH/Ui"
PRES_UI_SCREENS_PATH="$PRES_UI_PATH/screens"
FILE_PRES_FEATURE_SCREEN_VIEW="$PRES_UI_SCREENS_PATH/${FEATURE_NAME_SNAKE}_screen_view.dart"
PRES_UI_WIDGET_PATH="$PRES_UI_PATH/widget"

PRES_CUBITS_BASE_PATH="$PRESENTATION_PATH/cubits"
PRES_FEATURE_CUBIT_PATH="$PRES_CUBITS_BASE_PATH/${FEATURE_NAME_SNAKE}"
FILE_PRES_FEATURE_CUBIT="$PRES_FEATURE_CUBIT_PATH/${FEATURE_NAME_SNAKE}_cubit.dart"
FILE_PRES_FEATURE_CUBIT_STATE="$PRES_FEATURE_CUBIT_PATH/${FEATURE_NAME_SNAKE}_state.dart"

# --- Create Directory Structure for Feature ---
echo "Creating feature directories within '$BASE_PATH'..."
mkdir -p "$DATA_MODULE_REPO_PATH"
mkdir -p "$DATA_MODELS_FEATURE_PATH"
mkdir -p "$DATA_REMOTE_PATH"
mkdir -p "$DI_PATH"
mkdir -p "$DOMAIN_MODULE_REPO_PATH"
mkdir -p "$DOMAIN_FEATURE_USECASE_PATH"
mkdir -p "$PRES_UI_SCREENS_PATH"
mkdir -p "$PRES_UI_WIDGET_PATH"
mkdir -p "$PRES_FEATURE_CUBIT_PATH"
echo "Feature directories created."
echo ""

# --- Create Files and Populate Content for Feature ---
echo "Creating feature files and populating content..."

# lib/[MODULE_NAME].dart (Overwrites default)
cat <<EOF > "$FILE_LIB_MODULE_MAIN"
// lib/${MODULE_NAME_SNAKE}.dart
// This file typically exports the main router or screen for the module.
export './${MODULE_NAME_SNAKE}_screen_router.dart';
// Add other important exports for this module if needed
EOF
echo "Created/Updated: $FILE_LIB_MODULE_MAIN"

# lib/[MODULE_NAME]_screen_router.dart
cat <<EOF > "$FILE_LIB_MODULE_ROUTER"
// lib/${MODULE_NAME_SNAKE}_screen_router.dart
import 'package:core/utils/animations.dart'; // Assuming AppAnimations is available via core
import 'package:flutter/material.dart';
import 'presentation/Ui/screens/${FEATURE_NAME_SNAKE}_screen_view.dart';

class ${MODULE_NAME_PASCAL}ScreenRouter {
  ${MODULE_NAME_PASCAL}ScreenRouter._();

  static Route? onGenerateRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case ${FEATURE_NAME_PASCAL}ScreenView.id:
        return PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const ${FEATURE_NAME_PASCAL}ScreenView(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return AppAnimations.slideAnimation(animation, child);
          },
          transitionDuration: const Duration(milliseconds: 700),
        );
      // TODO: Add other routes specific to the ${MODULE_NAME_PASCAL} module here
      default:
        return null; 
    }
  }
}

class ${MODULE_NAME_PASCAL}Screens {
  ${MODULE_NAME_PASCAL}Screens._();
  static const String ${FEATURE_NAME_CAMEL}Screen = ${FEATURE_NAME_PASCAL}ScreenView.id;
}
EOF
echo "Created: $FILE_LIB_MODULE_ROUTER"

# lib/data/models/[FEATURE_NAME]/[FEATURE_NAME]_request.dart
cat <<EOF > "$FILE_DATA_FEATURE_REQUEST"
// lib/data/models/${FEATURE_NAME_SNAKE}/${FEATURE_NAME_SNAKE}_request.dart
import 'package:network/network.dart';
import './${FEATURE_NAME_SNAKE}_request_model.dart';

class ${FEATURE_NAME_PASCAL}Request with Request, PostRequest { // TODO: Adjust with GetRequest, etc. as needed
  const ${FEATURE_NAME_PASCAL}Request(this.requestModel);

  @override
  final ${FEATURE_NAME_PASCAL}RequestModel requestModel;

  @override
  String get path => '/${FEATURE_NAME_SNAKE}'; // TODO: Define your specific endpoint path
}
EOF
echo "Created: $FILE_DATA_FEATURE_REQUEST"

# lib/data/models/[FEATURE_NAME]/[FEATURE_NAME]_request_model.dart
cat <<EOF > "$FILE_DATA_FEATURE_REQUEST_MODEL"
// lib/data/models/${FEATURE_NAME_SNAKE}/${FEATURE_NAME_SNAKE}_request_model.dart
import 'package:network/network.dart'; // Assuming RequestModel is from here or a base class

class ${FEATURE_NAME_PASCAL}RequestModel extends RequestModel {
  // TODO: Define fields for your request model
  // Example: final String query;

  ${FEATURE_NAME_PASCAL}RequestModel({
    // Example: required this.query,
    RequestProgressListener? progressListener,
  }) : super(progressListener);

  @override
  Future<Map<String, dynamic>> toMap() async {
    // TODO: Implement conversion to map for the request body
    // Example: return {'query': query};
    return {};
  }

  @override
  List<Object?> get props => [/* query */]; // For equatable support
}
EOF
echo "Created: $FILE_DATA_FEATURE_REQUEST_MODEL"

# lib/data/models/[FEATURE_NAME]/[FEATURE_NAME]_response_model.dart
cat <<EOF > "$FILE_DATA_FEATURE_RESPONSE_MODEL"
// lib/data/models/${FEATURE_NAME_SNAKE}/${FEATURE_NAME_SNAKE}_response_model.dart

class ${FEATURE_NAME_PASCAL}Response {
  // TODO: Define fields for your response model
  // Example: final List<String> results;

  ${FEATURE_NAME_PASCAL}Response(
    // {required this.results}
  );

  factory ${FEATURE_NAME_PASCAL}Response.fromJson(Map<String, dynamic> json) {
    // TODO: Implement parsing from JSON
    // Example: return ${FEATURE_NAME_PASCAL}Response(results: List<String>.from(json['results']));
    return ${FEATURE_NAME_PASCAL}Response(); // Placeholder
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    // TODO: Implement conversion to JSON map
    // Example: data['results'] = this.results;
    return data;
  }
}
EOF
echo "Created: $FILE_DATA_FEATURE_RESPONSE_MODEL"

# lib/domain/[MODULE_NAME]_repository/[MODULE_NAME]_repository.dart (Interface)
cat <<EOF > "$FILE_DOMAIN_MODULE_REPO"
// lib/domain/${MODULE_NAME_SNAKE}_repository/${MODULE_NAME_SNAKE}_repository.dart
import 'package:core/packages/dartz/dartz.dart';
import 'package:failures/failures.dart';
import '../../data/models/${FEATURE_NAME_SNAKE}/${FEATURE_NAME_SNAKE}_request_model.dart';
import '../../data/models/${FEATURE_NAME_SNAKE}/${FEATURE_NAME_SNAKE}_response_model.dart';

abstract class ${MODULE_NAME_PASCAL}Repository {
  Future<Either<Failure, ${FEATURE_NAME_PASCAL}Response>> ${FEATURE_NAME_SNAKE}(
      {required ${FEATURE_NAME_PASCAL}RequestModel ${FEATURE_NAME_SNAKE}Data});
}
EOF
echo "Created: $FILE_DOMAIN_MODULE_REPO"

# lib/data/[MODULE_NAME]_repository/[MODULE_NAME]_repository_impl.dart (Implementation)
cat <<EOF > "$FILE_DATA_MODULE_REPO_IMPL"
// lib/data/${MODULE_NAME_SNAKE}_repository/${MODULE_NAME_SNAKE}_repository_impl.dart
import 'package:core/packages/dartz/dartz.dart';
import 'package:failures/failures.dart';
import '../../domain/${MODULE_NAME_SNAKE}_repository/${MODULE_NAME_SNAKE}_repository.dart';
import '../remote_data_source/${MODULE_NAME_SNAKE}_remote_data_source.dart';
import '../models/${FEATURE_NAME_SNAKE}/${FEATURE_NAME_SNAKE}_request_model.dart';
import '../models/${FEATURE_NAME_SNAKE}/${FEATURE_NAME_SNAKE}_response_model.dart';

class ${MODULE_NAME_PASCAL}RepositoryImpl implements ${MODULE_NAME_PASCAL}Repository {
  final ${MODULE_NAME_PASCAL}RemoteDataSource _${MODULE_NAME_CAMEL}RemoteDataSource;

  ${MODULE_NAME_PASCAL}RepositoryImpl({required ${MODULE_NAME_PASCAL}RemoteDataSource ${MODULE_NAME_CAMEL}RemoteDataSource})
      : _${MODULE_NAME_CAMEL}RemoteDataSource = ${MODULE_NAME_CAMEL}RemoteDataSource;

  @override
  Future<Either<Failure, ${FEATURE_NAME_PASCAL}Response>> ${FEATURE_NAME_SNAKE}(
      {required ${FEATURE_NAME_PASCAL}RequestModel ${FEATURE_NAME_SNAKE}Data}) async {
    try {
      final response = await _${MODULE_NAME_CAMEL}RemoteDataSource.${FEATURE_NAME_SNAKE}(${FEATURE_NAME_SNAKE}Data);
      return Right(response);
    } on Exception catch (error) {
      // Ensure FailureHandler is available, e.g., from 'package:failures/failures.dart'
      return Left(FailureHandler(error).getExceptionFailure());
    }
  }
}
EOF
echo "Created: $FILE_DATA_MODULE_REPO_IMPL"

# lib/data/remote_data_source/[MODULE_NAME_SNAKE]_remote_data_source.dart
cat <<EOF > "$FILE_DATA_MODULE_REMOTE_SOURCE"
// lib/data/remote_data_source/${MODULE_NAME_SNAKE}_remote_data_source.dart
import 'package:core/core.dart'; // For Network, etc.
import '../models/${FEATURE_NAME_SNAKE}/${FEATURE_NAME_SNAKE}_request.dart';
import '../models/${FEATURE_NAME_SNAKE}/${FEATURE_NAME_SNAKE}_request_model.dart';
import '../models/${FEATURE_NAME_SNAKE}/${FEATURE_NAME_SNAKE}_response_model.dart';

abstract class ${MODULE_NAME_PASCAL}RemoteDataSource {
  Future<${FEATURE_NAME_PASCAL}Response> ${FEATURE_NAME_SNAKE}(
      ${FEATURE_NAME_PASCAL}RequestModel ${FEATURE_NAME_SNAKE}Data);
}

class ${MODULE_NAME_PASCAL}RemoteDataSourceImpl implements ${MODULE_NAME_PASCAL}RemoteDataSource {
  final Network network; // Assuming Network type is from 'package:core/core.dart' or similar

  ${MODULE_NAME_PASCAL}RemoteDataSourceImpl({required this.network});

  @override
  Future<${FEATURE_NAME_PASCAL}Response> ${FEATURE_NAME_SNAKE}(
      ${FEATURE_NAME_PASCAL}RequestModel ${FEATURE_NAME_SNAKE}Data) async {
    final apiRequest = ${FEATURE_NAME_PASCAL}Request(${FEATURE_NAME_SNAKE}Data);
    
    final result = await network.send(
      request: apiRequest,
      responseFromMap: (map) => ${FEATURE_NAME_PASCAL}Response.fromJson(map),
    );
    return result;
  }
}
EOF
echo "Created: $FILE_DATA_MODULE_REMOTE_SOURCE"

# lib/domain/[MODULE_NAME]_usecase/[FEATURE_NAME]_usecase/[FEATURE_NAME]_usecase.dart
cat <<EOF > "$FILE_DOMAIN_FEATURE_USECASE"
// lib/domain/${MODULE_NAME_SNAKE}_usecase/${FEATURE_NAME_SNAKE}_usecase/${FEATURE_NAME_SNAKE}_usecase.dart
import 'package:core/packages/dartz/dartz.dart';
import 'package:core/usecase/usecase.dart';
import 'package:failures/failures.dart';
import '../../../../data/models/${FEATURE_NAME_SNAKE}/${FEATURE_NAME_SNAKE}_request_model.dart';
import '../../../../data/models/${FEATURE_NAME_SNAKE}/${FEATURE_NAME_SNAKE}_response_model.dart';
import '../../../${MODULE_NAME_SNAKE}_repository/${MODULE_NAME_SNAKE}_repository.dart';

class ${FEATURE_NAME_PASCAL}UseCase
    implements UseCase<${FEATURE_NAME_PASCAL}Response, ${FEATURE_NAME_PASCAL}RequestModel> {
  final ${MODULE_NAME_PASCAL}Repository _repository;

  ${FEATURE_NAME_PASCAL}UseCase(this._repository);

  @override
  Future<Either<Failure, ${FEATURE_NAME_PASCAL}Response>> call(
      ${FEATURE_NAME_PASCAL}RequestModel params) async {
    return await _repository.${FEATURE_NAME_SNAKE}(${FEATURE_NAME_SNAKE}Data: params);
  }
}
EOF
echo "Created: $FILE_DOMAIN_FEATURE_USECASE"

# lib/presentation/cubits/[FEATURE_NAME]/[FEATURE_NAME]_state.dart
cat <<EOF > "$FILE_PRES_FEATURE_CUBIT_STATE"
// lib/presentation/cubits/${FEATURE_NAME_SNAKE}/${FEATURE_NAME_SNAKE}_state.dart
part of '${FEATURE_NAME_SNAKE}_cubit.dart';

class ${FEATURE_NAME_PASCAL}State extends BaseState { // Assuming BaseState from 'package:core/core.dart'
  const ${FEATURE_NAME_PASCAL}State({
    this.failure,
    this.featureData,
    super.screenLoading = false, 
  });

  final Failure? failure; // Assuming Failure from 'package:failures/failures.dart'
  final ${FEATURE_NAME_PASCAL}Response? featureData;

  @override
  ${FEATURE_NAME_PASCAL}State copyWith({
    Failure? failure,
    bool? screenLoading,
    ${FEATURE_NAME_PASCAL}Response? featureData,
  }) {
    return ${FEATURE_NAME_PASCAL}State(
      failure: failure ?? this.failure,
      screenLoading: screenLoading ?? this.screenLoading,
      featureData: featureData ?? this.featureData,
    );
  }

  @override
  List<Object?> get props => [
        screenLoading,
        failure,
        featureData,
      ];
}
EOF
echo "Created: $FILE_PRES_FEATURE_CUBIT_STATE"

# lib/presentation/cubits/[FEATURE_NAME]/[FEATURE_NAME]_cubit.dart
cat <<EOF > "$FILE_PRES_FEATURE_CUBIT"
// lib/presentation/cubits/${FEATURE_NAME_SNAKE}/${FEATURE_NAME_SNAKE}_cubit.dart
import 'package:core/core.dart'; // For BaseCubit
import 'package:core/packages/dartz/dartz.dart';
import 'package:failures/failures.dart';
import 'package:local_storage/local_storage.dart'; // TODO: Ensure this import is correct
import '../../../data/models/${FEATURE_NAME_SNAKE}/${FEATURE_NAME_SNAKE}_request_model.dart';
import '../../../data/models/${FEATURE_NAME_SNAKE}/${FEATURE_NAME_SNAKE}_response_model.dart';
import '../../../domain/${MODULE_NAME_SNAKE}_usecase/${FEATURE_NAME_SNAKE}_usecase/${FEATURE_NAME_SNAKE}_usecase.dart';

part '${FEATURE_NAME_SNAKE}_state.dart';

class ${FEATURE_NAME_PASCAL}Cubit extends BaseCubit<${FEATURE_NAME_PASCAL}State> {
  final LocalStorage localStorage; // TODO: Ensure LocalStorage is provided/injected
  final ${FEATURE_NAME_PASCAL}UseCase _${FEATURE_NAME_CAMEL}UseCase;

  ${FEATURE_NAME_PASCAL}Cubit(
    this.localStorage,
    this._${FEATURE_NAME_CAMEL}UseCase,
  ) : super(const ${FEATURE_NAME_PASCAL}State());

  @override
  Future<void> initState() async {
    // TODO: Implement initial state setup, e.g., call get${FEATURE_NAME_PASCAL}()
  }

  Future<void> get${FEATURE_NAME_PASCAL}() async {
    emit(state.copyWith(screenLoading: true));
    // TODO: Pass appropriate parameters to RequestModel if it's not default constructible
    final Either<Failure, ${FEATURE_NAME_PASCAL}Response> response =
        await _${FEATURE_NAME_CAMEL}UseCase.call(
      ${FEATURE_NAME_PASCAL}RequestModel(), 
    );

    response.fold(
      (failure) => emit(state.copyWith(failure: failure, screenLoading: false)),
      (data) {
        emit(
          state.copyWith(
            featureData: data, 
            screenLoading: false,
          ),
        );
      },
    );
  }
}
EOF
echo "Created: $FILE_PRES_FEATURE_CUBIT"

# lib/presentation/Ui/screens/[FEATURE_NAME]_screen_view.dart
cat <<EOF > "$FILE_PRES_FEATURE_SCREEN_VIEW"
// lib/presentation/Ui/screens/${FEATURE_NAME_SNAKE}_screen_view.dart
import 'package:core/core.dart'; // For BaseView
import 'package:flutter/material.dart';
import 'package:ui_components/ui_components.dart'; // For AppColors, etc.
import '../../cubits/${FEATURE_NAME_SNAKE}/${FEATURE_NAME_SNAKE}_cubit.dart';

class ${FEATURE_NAME_PASCAL}ScreenView extends BaseView<${FEATURE_NAME_PASCAL}Cubit> {
  static const String id = '/${FEATURE_NAME_PASCAL}ScreenView';

  const ${FEATURE_NAME_PASCAL}ScreenView({super.key});

  @override
  PreferredSizeWidget? appBar(BuildContext context) {
    return AppBar(title: Text('${FEATURE_NAME_PASCAL} Screen'));
  }

  @override
  Widget body(BuildContext context) {
    // TODO: Build your UI, use BlocBuilder, BlocListener for state changes from ${FEATURE_NAME_PASCAL}Cubit
    return Scaffold(
      // appBar: appBar(context), // BaseView might handle this
      backgroundColor: AppColors.whiteColor, // Ensure AppColors is available
      body: Center(
        child: Text('Welcome to the ${FEATURE_NAME_PASCAL} Screen!'),
      ),
    );
  }
}
EOF
echo "Created: $FILE_PRES_FEATURE_SCREEN_VIEW"

# lib/di/[MODULE_NAME]_di.dart
cat <<EOF > "$FILE_DI_MODULE_MAIN"
// lib/di/${MODULE_NAME_SNAKE}_di.dart
import 'package:get_it/get_it.dart';
// TODO: Ensure imports for LocalStorage, Network from your core/shared packages
// Example: import 'package:local_storage/local_storage.dart';
// Example: import 'package:core/network.dart'; // Assuming Network type definition

import '../data/remote_data_source/${MODULE_NAME_SNAKE}_remote_data_source.dart';
import '../data/${MODULE_NAME_SNAKE}_repository/${MODULE_NAME_SNAKE}_repository_impl.dart';
import '../domain/${MODULE_NAME_SNAKE}_repository/${MODULE_NAME_SNAKE}_repository.dart';
import '../domain/${MODULE_NAME_SNAKE}_usecase/${FEATURE_NAME_SNAKE}_usecase/${FEATURE_NAME_SNAKE}_usecase.dart';
import '../presentation/cubits/${FEATURE_NAME_SNAKE}/${FEATURE_NAME_SNAKE}_cubit.dart';

final sl = GetIt.instance;

Future<void> init${MODULE_NAME_PASCAL}DI() async {
  // Ensure foundational dependencies like Network and LocalStorage are registered.
  // If they are provided by a higher-level DI setup, this is fine.
  // If they need to be registered per module, or if this is the main DI:
  // if (!sl.isRegistered<Network>()) {
  //   sl.registerLazySingleton<Network>(() => NetworkImpl()); // Provide actual implementation
  // }
  // if (!sl.isRegistered<LocalStorage>()) {
  //   sl.registerLazySingleton<LocalStorage>(() => LocalStorageImpl()); // Provide actual implementation
  // }

  // Data Sources
  sl.registerLazySingleton<${MODULE_NAME_PASCAL}RemoteDataSource>(
    () => ${MODULE_NAME_PASCAL}RemoteDataSourceImpl(network: sl()),
  );

  // Repositories
  sl.registerLazySingleton<${MODULE_NAME_PASCAL}Repository>(
    () => ${MODULE_NAME_PASCAL}RepositoryImpl(${MODULE_NAME_CAMEL}RemoteDataSource: sl()),
  );

  // Use Cases
  sl.registerLazySingleton(
    () => ${FEATURE_NAME_PASCAL}UseCase(sl()),
  );

  // Cubits
  sl.registerFactory(
    () => ${FEATURE_NAME_PASCAL}Cubit(
      sl<LocalStorage>(), 
      sl<${FEATURE_NAME_PASCAL}UseCase>(),
    ),
  );
}
EOF
echo "Created: $FILE_DI_MODULE_MAIN"


echo ""
echo "✅ Flutter module '$MODULE_NAME_SNAKE' created and initial feature '$FEATURE_NAME_SNAKE' scaffolded successfully."
echo "   Module Location: $(cd ..; pwd)/$MODULE_NAME_SNAKE" # Shows original path then module name
echo "   Next steps:"
echo "   1. Review and complete TODOs in the generated files (especially models, DI registrations, UI)."
echo "   2. Add '$MODULE_NAME_SNAKE' to your main app's pubspec.yaml if it's a local package."
echo "   3. Call 'await init${MODULE_NAME_PASCAL}DI();' from your main application's DI setup."
echo "   4. Integrate the '${MODULE_NAME_PASCAL}ScreenRouter' into your app's routing mechanism."
cd .. # Go back to the original directory where the script was run
echo "Returned to: $PWD"