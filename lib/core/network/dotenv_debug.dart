import 'package:flutter_dotenv/flutter_dotenv.dart';

String debugBaseUrl() => dotenv.maybeGet('API_BASE_URL') ?? '<not set>';
