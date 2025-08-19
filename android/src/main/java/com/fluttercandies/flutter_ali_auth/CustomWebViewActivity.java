package com.fluttercandies.flutter_ali_auth;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.pm.ActivityInfo;

import android.os.Build;
import android.os.Bundle;
import android.view.MenuItem;

import android.view.View;
import android.view.Window;
import android.view.WindowManager;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;

import androidx.annotation.Nullable;
import androidx.appcompat.app.ActionBar;
import androidx.appcompat.app.AppCompatActivity;
import androidx.appcompat.widget.Toolbar;
import androidx.core.content.ContextCompat;
import android.graphics.Color;
import android.view.KeyEvent;
import com.mobile.auth.gatewayauth.Constant;


/**
 * @ProjectName: NumberAuthSDK_Standard_Android
 * @Package: com.aliqin.mytel.auth
 * @ClassName: CustomWebView
 * @Description: 自定义协议展示页
 * @Author: liuqi
 * @CreateDate: 2021/3/25 4:04 PM
 * @Version: 1.0
 */
public class CustomWebViewActivity extends AppCompatActivity {
    private WebView mWebView;
    private Toolbar mToolbar;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_custom_web);

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            Window window = getWindow();
            window.clearFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_STATUS);
            window.addFlags(WindowManager.LayoutParams.FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS);
            window.setStatusBarColor(ContextCompat.getColor(this, R.color.white));
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                window.getDecorView().setSystemUiVisibility(View.SYSTEM_UI_FLAG_LIGHT_STATUS_BAR);
            }
        }


        String mUrl = getIntent().getStringExtra(Constant.PROTOCOL_WEB_VIEW_URL);
        String mName = getIntent().getStringExtra(Constant.PROTOCOL_WEB_VIEW_NAME);
        setRequestedOrientation(
                getIntent().getIntExtra(Constant.PROTOCOL_WEB_VIEW_ORIENTATION, ActivityInfo.SCREEN_ORIENTATION_PORTRAIT));
        mWebView = findViewById(R.id.webView);
        mWebView.setWebViewClient(new WebViewClient() {
            @Override
            public boolean shouldOverrideUrlLoading(WebView view, String url) {
                if (url.startsWith("tel:") || url.startsWith("mailto:")) {
                    return true;
                }
                view.loadUrl(url);
                return true;
            }
        });
        mToolbar = findViewById(R.id.toolbar);
        mToolbar.setTitleTextColor(getResources().getColor(R.color.black));
        mToolbar.setTitle(mName);
        setSupportActionBar(mToolbar);
        ActionBar actionBar = getSupportActionBar();
        if (actionBar != null) {
            actionBar.setDisplayHomeAsUpEnabled(true);
        }
        initWebView();
        mWebView.loadUrl(mUrl);
    }

    @SuppressLint("SetJavaScriptEnabled")
    private void initWebView() {
        WebSettings wvSettings = mWebView.getSettings();
        wvSettings.setBlockNetworkImage(false);
        wvSettings.setBlockNetworkLoads(false);
        wvSettings.setJavaScriptEnabled(true);
        wvSettings.setJavaScriptCanOpenWindowsAutomatically(true);
        wvSettings.setCacheMode(WebSettings.LOAD_DEFAULT);
        wvSettings.setUseWideViewPort(true);
        wvSettings.setLoadWithOverviewMode(true);
        wvSettings.setDomStorageEnabled(true);
        wvSettings.setBuiltInZoomControls(false);
        wvSettings.setSupportZoom(false);
        wvSettings.setDisplayZoomControls(false);
        wvSettings.setAllowFileAccess(true);
        wvSettings.setDatabaseEnabled(true);
        // wvSettings.setAppCacheEnabled(true);
        wvSettings.setDomStorageEnabled(true);
        wvSettings.setDatabaseEnabled(true);
    }
    @Override
    public void onBackPressed() {
        if (mWebView != null && mWebView.canGoBack()){
            mWebView.goBack();
        }else{
            super.onBackPressed();
        }

    }

    @Override
    public boolean onOptionsItemSelected(android.view.MenuItem item) {
        if (item.getItemId() == android.R.id.home) {
            onBackPressed();
            return true;
        }
        return super.onOptionsItemSelected(item);
    }

}
