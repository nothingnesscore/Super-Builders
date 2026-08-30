package com.nothingnesscore.kaoripatcher

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.Scaffold
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import com.nothingnesscore.kaoripatcher.ui.components.LiquidGlassNavBar
import com.nothingnesscore.kaoripatcher.ui.screens.HomeScreen
import com.nothingnesscore.kaoripatcher.ui.screens.PatcherScreen
import com.nothingnesscore.kaoripatcher.ui.theme.KaoriOSPatcherTheme

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            KaoriOSPatcherTheme {
                MainApp()
            }
        }
    }
}

@Composable
fun MainApp() {
    var selectedTab by remember { mutableStateOf(0) }

    Scaffold(
        bottomBar = {
            LiquidGlassNavBar(
                selectedTab = selectedTab,
                onTabSelected = { selectedTab = it }
            )
        }
    ) { innerPadding ->
        Box(modifier = Modifier.fillMaxSize()) {
            when (selectedTab) {
                0 -> HomeScreen()
                1 -> PatcherScreen()
                2 -> { /* Settings Screen */ }
            }
        }
    }
}
