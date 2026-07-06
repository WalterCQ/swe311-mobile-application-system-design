package com.example.retro_tech_marketplace

import android.content.ActivityNotFoundException
import android.content.Intent
import android.net.Uri
import android.os.Build
import androidx.core.content.FileProvider
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "retro_tech_marketplace/app_update"
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "getAppInfo" -> {
                    val packageInfo = packageManager.getPackageInfo(packageName, 0)
                    val versionCode = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                        packageInfo.longVersionCode
                    } else {
                        @Suppress("DEPRECATION")
                        packageInfo.versionCode.toLong()
                    }
                    result.success(
                        mapOf(
                            "versionName" to (packageInfo.versionName ?: ""),
                            "buildNumber" to versionCode.toString()
                        )
                    )
                }
                "getUpdateCacheDir" -> {
                    result.success(cacheDir.absolutePath)
                }
                "installApk" -> {
                    val filePath = call.argument<String>("filePath")
                    if (filePath.isNullOrBlank()) {
                        result.error("invalid_apk", "Missing APK file path.", null)
                        return@setMethodCallHandler
                    }

                    val apkFile = File(filePath)
                    if (!apkFile.exists() || !apkFile.isFile) {
                        result.error("invalid_apk", "APK file does not exist.", null)
                        return@setMethodCallHandler
                    }

                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O &&
                        !packageManager.canRequestPackageInstalls()
                    ) {
                        result.error(
                            "unknown_sources_disabled",
                            "Allow installs from this app in Android settings, then retry.",
                            null
                        )
                        return@setMethodCallHandler
                    }

                    try {
                        val apkUri = FileProvider.getUriForFile(
                            this,
                            "${packageName}.update_provider",
                            apkFile
                        )
                        val intent = Intent(Intent.ACTION_INSTALL_PACKAGE).apply {
                            setDataAndType(apkUri, "application/vnd.android.package-archive")
                            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                            putExtra(Intent.EXTRA_NOT_UNKNOWN_SOURCE, true)
                            putExtra(Intent.EXTRA_RETURN_RESULT, true)
                        }
                        startActivity(intent)
                        result.success(true)
                    } catch (error: ActivityNotFoundException) {
                        result.error("installer_not_found", error.message, null)
                    } catch (error: IllegalArgumentException) {
                        result.error("install_apk_failed", error.message, null)
                    } catch (error: Exception) {
                        result.error("install_apk_failed", error.message, null)
                    }
                }
                "openUrl" -> {
                    val url = call.argument<String>("url")
                    if (url.isNullOrBlank()) {
                        result.error("invalid_url", "Missing update URL.", null)
                        return@setMethodCallHandler
                    }
                    try {
                        val intent = Intent(Intent.ACTION_VIEW, Uri.parse(url))
                        startActivity(intent)
                        result.success(true)
                    } catch (error: Exception) {
                        result.error("open_url_failed", error.message, null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }
}
