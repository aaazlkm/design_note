package com.example.design_note_android.favoritebutton

import android.graphics.Rect
import android.graphics.drawable.Drawable
import androidx.compose.animation.core.*
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.material.Icon
import androidx.compose.material.IconToggleButton
import androidx.compose.material.Scaffold
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.drawscope.drawIntoCanvas
import androidx.compose.ui.graphics.drawscope.scale
import androidx.compose.ui.graphics.drawscope.translate
import androidx.compose.ui.graphics.nativeCanvas
import androidx.compose.ui.graphics.toArgb
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.painterResource
import androidx.core.content.ContextCompat
import androidx.core.graphics.drawable.DrawableCompat
import com.example.design_note_android.R
import kotlin.random.Random

@Composable
fun FavoriteButtonScreen() {
    var favorited = remember {
        mutableStateOf(false)
    }

    Scaffold(
        modifier = Modifier
            .fillMaxSize()
            .background(Color.Blue),
    ) {
        Box(
            modifier = Modifier
                .fillMaxSize()
                .padding(it)
                .background(Color.LightGray),
            contentAlignment = Alignment.Center,
        ) {
            FavoriteAnimation(
                visible = favorited.value,
            )
            IconToggleButton(
                checked = favorited.value,
                content = {
                    if (favorited.value) {
                        Icon(
                            painterResource(id = R.drawable.ic_baseline_favorite_24),
                            "favorite",
                            tint = Color.Red
                        )
                    } else {
                        Icon(
                            painterResource(id = R.drawable.ic_baseline_favorite_border_24),
                            "favorite"
                        )
                    }
                },
                onCheckedChange = {
                    favorited.value = !favorited.value
                }
            )
        }
    }
}

@Composable
fun FavoriteAnimation(
    visible: Boolean,
) {
    val transitionState = remember {
        MutableTransitionState(visible)
    }
    val targetChanged = transitionState.targetState != visible
    transitionState.targetState = visible
    val transition = updateTransition(targetState = transitionState, label = "")
    val animatedFraction by transition.animateFloat(
        transitionSpec = {
            tween(
                durationMillis = if (visible) 400 else 0,
                easing = LinearEasing,
            )
        },
        label = "",
    ) {
        if (it.targetState) 1f else 0f
    }

    val hearts = remember { List(10) { Heart() } }
    hearts.forEach { heart ->
        heart.reset()
    }
    FavoriteAnimation(
        hearts = hearts,
        fraction = animatedFraction,
    )
}

private val moveInterpolator = FastOutSlowInEasing
private val alphaInterpolator = FastOutLinearInEasing
private val scaleInterpolator = LinearOutSlowInEasing

@Composable
fun FavoriteAnimation(
    hearts: List<Heart>,
    fraction: Float,
) {
    val moveProgress = moveInterpolator.transform(fraction)
    val scaleProgress = scaleInterpolator.transform(fraction)
    val context = LocalContext.current
    val drawable = rememberHeartDrawable()
    val drawableHalfWidth = drawable.intrinsicWidth / 2f
    val drawableHalfHeight = drawable.intrinsicHeight / 2f

    Canvas(
        modifier = Modifier.fillMaxSize(),
    ) {
        val width = size.width
        val height = size.height
        hearts.forEach {
            val x = lerp(width / 2, it.targetX * width, moveInterpolator.transform(fraction))
            val y = lerp(height - drawableHalfHeight, it.targetY * height, moveInterpolator.transform(fraction))
            translate(x, y) {
                scale(
                    scaleX = scaleInterpolator.transform(fraction),
                    scaleY = scaleInterpolator.transform(fraction),
                    pivot = Offset(0.5f, 0.5f),
                ) {
                    drawIntoCanvas { canvas ->
                        drawable.alpha = lerp(0f, 255f, alphaInterpolator.transform(fraction)).toInt()
                        drawable.draw(canvas.nativeCanvas)
                    }
                }
            }
        }
    }
}

@Composable
private fun rememberHeartDrawable(): Drawable {
    val context = LocalContext.current
    return remember {
        ContextCompat.getDrawable(context, R.drawable.ic_baseline_favorite_24)!!
            .apply {
                DrawableCompat.setTint(this, Color.Red.toArgb())

                val halfWidth = intrinsicWidth / 2
                val halfHeight = intrinsicHeight / 2
                bounds = Rect(-halfWidth, -halfHeight, halfWidth, halfHeight)
            }
    }
}

data class Heart(
    var targetX: Float = lerp(0f, 1f, Random.nextFloat()),
    var targetY: Float = lerp(0f, 1f, Random.nextFloat()),
) {
    fun reset() {
        targetX = lerp(0f, 1f, Random.nextFloat())
        targetY = lerp(0f, 1f, Random.nextFloat())
    }
}

fun lerp(start: Float, stop: Float, fraction: Float) =
    (start * (1 - fraction) + stop * fraction)
