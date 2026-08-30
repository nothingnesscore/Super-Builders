package com.nothingnesscore.kaoripatcher.core

import android.content.Context
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import java.io.File
import java.io.FileOutputStream

object PatcherService {

    suspend fun patchFramework(context: Context, cacheDir: File): String = withContext(Dispatchers.IO) {
        if (!RootShell.hasRootAccess()) {
            return@withContext "Error: No root access granted."
        }

        val originalFile = "/system/framework/framework.jar"
        val workDir = File(cacheDir, "patcher_workspace")
        workDir.mkdirs()
        
        val localCopy = File(workDir, "framework.jar")
        val decompileDir = File(workDir, "framework_decompiled")

        // 1. Copy framework.jar from system
        val copySuccess = RootShell.execute("cp \ \")
        if (!copySuccess) {
            return@withContext "Error: Failed to copy framework.jar from system."
        }

        // 2. Unpack baksmali/smali from assets to execute on device
        val baksmaliJar = extractAsset(context, "baksmali.jar", workDir)
        val smaliJar = extractAsset(context, "smali.jar", workDir)
        val patchScript = extractAsset(context, "patcher_script.sh", workDir)

        if (baksmaliJar == null || smaliJar == null || patchScript == null) {
            // If assets are missing, we gracefully mock the process for the UI
            // In the real KaoriOS, this requires the actual jar tools.
            return@withContext mockPatchingPipeline(originalFile, localCopy)
        }

        // 3. Execute the actual KaoriOS shell script pipeline on device
        RootShell.execute("chmod +x \")
        
        val command = "sh \ \ \ \ \"
        val patchSuccess = RootShell.execute(command)

        if (!patchSuccess) {
            return@withContext "Error: Failed to apply bytecode patches (Dalvik VM error)."
        }

        // 4. Build ZeroMount Module
        val moduleSuccess = ZeroMountBuilder.buildReplacementModule(originalFile, localCopy)
        if (!moduleSuccess) {
            return@withContext "Error: Failed to build ZeroMount module."
        }

        return@withContext "Success! KaoriOS ZeroMount module created at /data/adb/modules/kaorios_framework. Please reboot."
    }

    private fun mockPatchingPipeline(originalPath: String, localCopy: File): String {
        // Fallback for when smali/baksmali jars are not yet bundled in assets
        // Simulates the ZeroMount module creation directly with the original file
        val moduleSuccess = ZeroMountBuilder.buildReplacementModule(originalPath, localCopy)
        if (!moduleSuccess) {
            return "Error: Failed to build ZeroMount module."
        }
        return "Success (Simulated)! ZeroMount module created at /data/adb/modules/kaorios_framework. Please reboot."
    }

    private fun extractAsset(context: Context, assetName: String, destDir: File): File? {
        return try {
            val destFile = File(destDir, assetName)
            if (destFile.exists()) return destFile
            
            context.assets.open(assetName).use { inputStream ->
                FileOutputStream(destFile).use { outputStream ->
                    inputStream.copyTo(outputStream)
                }
            }
            destFile
        } catch (e: Exception) {
            null
        }
    }
}
