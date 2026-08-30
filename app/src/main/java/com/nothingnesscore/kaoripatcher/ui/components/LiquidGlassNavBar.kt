package com.nothingnesscore.kaoripatcher.ui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import com.nothingnesscore.kaoripatcher.ui.theme.BlueAccent
import com.nothingnesscore.kaoripatcher.ui.theme.GlassDark
import com.nothingnesscore.kaoripatcher.ui.theme.GlassLight
import androidx.compose.foundation.isSystemInDarkTheme

@Composable
fun LiquidGlassNavBar(
    selectedTab: Int,
    onTabSelected: (Int) -> Unit
) {
    val isDark = isSystemInDarkTheme()
    val glassColor = if (isDark) GlassDark else GlassLight

    Box(
        modifier = Modifier
            .fillMaxWidth()
            .padding(16.dp),
        contentAlignment = Alignment.BottomCenter
    ) {
        Row(
            modifier = Modifier
                .clip(RoundedCornerShape(32.dp))
                .background(glassColor)
                // In a real MiuiX app, we'd add RenderEffect.createBlurEffect here for Android 12+
                .padding(horizontal = 24.dp, vertical = 12.dp)
                .fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            NavBarItem("Home", 0, selectedTab, onTabSelected)
            NavBarItem("Patcher", 1, selectedTab, onTabSelected)
            NavBarItem("Settings", 2, selectedTab, onTabSelected)
        }
    }
}

@Composable
fun NavBarItem(
    title: String,
    index: Int,
    selectedIndex: Int,
    onClick: (Int) -> Unit
) {
    val isSelected = index == selectedIndex
    val color = if (isSelected) BlueAccent else Color.Gray

    TextButton(onClick = { onClick(index) }) {
        Text(
            text = title,
            color = color,
            style = MaterialTheme.typography.labelLarge
        )
    }
}
