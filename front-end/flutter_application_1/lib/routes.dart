import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/ChatScreen.dart';
import "screens/SplashScreen.dart";
import 'screens/DashboardScreen.dart';
import 'screens/LoginScreen.dart';
import 'screens/RegisterScreen.dart';
import 'screens/AllAnalyses_Screen.dart';
import 'screens/AddTauleAnalysisScreen.dart';
import 'screens/AddAudioAnalysisScreen.dart';
import 'screens/PricePredictionScreen.dart';
import 'screens/AllIssuesScreen.dart';
import 'screens/IssueDetailsScreen.dart';
import 'screens/AnalysisDetailsScreen.dart';

class Routes {
static String Issue_details="/issue_details";
static String Analysis_details="/analysis_details";
static String AllIssues_route="/all_issues";
static String AllAnalyses_route="/all_analyses";
static String addAudioAnalysis_route ="/add_audio_analysis";
static String AddTauleAnalysis_route ="/add_taule_analysis";
static String PricePrediction_route="/price_prediction";
static String splash_route="/splashScreen";
static String login_route="/loginScreen";
static String register_route="/registerScreen";
static String dashboard_route="/dashboardScreen";
static String Chat_route="/chatScreen";
static String logout_route="/logout";
static Map <String,WidgetBuilder> all_routes={

  splash_route:(context)=>SplashScreen(),
  AllIssues_route:(context)=>AllIssuesScreen(),
  login_route:(context)=>LoginScreen(),
  logout_route:(context)=>LoginScreen(),
  register_route:(context)=>RegisterScreen(),
  dashboard_route:(context)=> DashboardScreen(),
  AllAnalyses_route:(context)=>AllAnalyses_Screen(),
  addAudioAnalysis_route:(context)=>AddAudioAnalysisScreen(),
  AddTauleAnalysis_route:(context)=>AddTauleAnalysisScreen(),
  Chat_route:(context)=>Chatscreen(),
  PricePrediction_route: (context) => PredictionScreen(),
  Issue_details: (context) => IssueDetailsScreen(),
  Analysis_details: (context) => AnalysisDetailsScreen(),

};

}
