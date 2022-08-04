package com.example.design_note_android

import android.os.Bundle
import androidx.activity.compose.setContent
import androidx.appcompat.app.AppCompatActivity
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.material.MaterialTheme
import androidx.compose.material.Scaffold
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import com.example.design_note_android.favoritebutton.FavoriteButtonScreen

class MainActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            MaterialTheme {
                AppContent()
            }
        }
    }
}

sealed class AppRoutes {
    object Home : AppRoutes()

    val path: String
        get() = when (this) {
            Home -> "home"
        }
}

@Composable
fun AppContent() {
    val navController = rememberNavController()
    Scaffold(
        modifier = Modifier
            .fillMaxSize()
    ) { innerPadding ->
        NavHost(
            navController = navController,
            startDestination = AppRoutes.Home.path,
            modifier = Modifier.padding(innerPadding),
        ) {
            composable(AppRoutes.Home.path) {
                FavoriteButtonScreen()
            }
        }
    }
}
