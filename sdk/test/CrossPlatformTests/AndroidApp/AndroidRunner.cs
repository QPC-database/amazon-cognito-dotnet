using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

using Android.App;
using Android.Content;
using Android.OS;
using Android.Runtime;
using Android.Views;
using Android.Widget;
using CommonTests.Framework;
using System.IO;


namespace AndroidApp
{
    public class AndroidRunner : TestRunner
    {
        private TextView _textView = null;
        private Action<Action> _uiRunner = null;

        public AndroidRunner(Stream credentials, TextView txtView, Action<Action> uiRunner)
            : base()
        {
            _textView = txtView;
            _uiRunner = uiRunner;
        }

        protected override void WriteLine(string message)
        {
            _uiRunner(() => _textView.Append("\n" + message));
        }
    }
}