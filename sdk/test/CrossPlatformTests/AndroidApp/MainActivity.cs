﻿using System;
using Android.App;
using Android.Content;
using Android.Runtime;
using Android.Views;
using Android.Widget;
using Android.OS;
using CommonTests.Framework;
using Android.Text.Method;

namespace AndroidApp
{
    [Activity(Label = "AndroidApp", MainLauncher = true, Icon = "@drawable/icon")]
    public class MainActivity : Activity
    {
        public const string CredentialsAsset = "credentials.json";
        int count = 1;
        TestRunner runner = null;

        protected override void OnCreate(Bundle bundle)
        {
            base.OnCreate(bundle);

            // Set our view from the "main" layout resource
            SetContentView(Resource.Layout.Main);

            // Get our button from the layout resource,
            // and attach an event to it
            Button button = FindViewById<Button>(Resource.Id.MyButton);
            //button.Click += delegate { button.Text = string.Format("{0} clicks!", count++); };
            button.Click += OnClick;
            var txtBox = FindViewById<TextView>(Resource.Id.TestOutput);
            txtBox.MovementMethod = new ScrollingMovementMethod();

            var stream = Assets.Open(CredentialsAsset);
            txtBox.Text = "Executing tests...";
            runner = new AndroidRunner(stream, txtBox, RunOnUiThread);
            runner.ExecuteAllTestsAsync();
        }

        async void OnClick(object sender, EventArgs e)
        {
            Button button = FindViewById<Button>(Resource.Id.MyButton);
            button.Text = string.Format("{0} clicks!", count++);
            await runner.ExecuteAllTestsAsync();

        }
    }
}

