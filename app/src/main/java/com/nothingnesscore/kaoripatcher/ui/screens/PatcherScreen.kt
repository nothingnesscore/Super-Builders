package com.nothingnesscore.kaoripatcher.ui.screens

import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.unit.dp
import com.nothingnesscore.kaoripatcher.core.PatcherService
import kotlinx.coroutines.launch

@Composable
fun PatcherScreen() {
    var statusText by remember { mutableStateOf("Ready to patch framework.jar") }
    var isPatching by remember { mutableStateOf(false) }
    val coroutineScope = rememberCoroutineScope()
    val context = LocalContext.current

    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(16.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center
    ) {
        Text(
            text = "KaoriOS ZeroMount Patcher",
            style = MaterialTheme.typography.headlineMedium
        )
        
        Spacer(modifier = Modifier.height(32.dp))
        
        Text(
            text = statusText,
            style = MaterialTheme.typography.bodyLarge
        )

        Spacer(modifier = Modifier.height(32.dp))

        Button(
            onClick = {
                isPatching = true
                statusText = "Patching in progress (extracting framework)..."
                coroutineScope.launch {
                    statusText = PatcherService.patchFramework(context, context.cacheDir)
                    isPatching = false
                }
            },
            enabled = !isPatching,
            modifier = Modifier.fillMaxWidth(0.8f).height(56.dp)
        ) {
            if (isPatching) {
                CircularProgressIndicator(color = MaterialTheme.colorScheme.onPrimary)
            } else {
                Text("Start Patching")
            }
        }
    }
}
