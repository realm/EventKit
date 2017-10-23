package io.realm.conference.ui.splash

import android.app.ProgressDialog
import android.arch.lifecycle.LifecycleActivity
import android.arch.lifecycle.Observer
import android.arch.lifecycle.ViewModelProviders
import android.os.Bundle
import android.support.design.widget.Snackbar
import io.realm.conference.R
import io.realm.conference.ui.common.ConferenceActivity
import io.realm.conference.viewmodel.splash.SplashViewModel
import kotlinx.android.synthetic.main.activity_splash.*
import org.jetbrains.anko.startActivity

class SplashActivity : LifecycleActivity() {

    lateinit var progressDialog: ProgressDialog
    lateinit var viewModel: SplashViewModel

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        viewModel = ViewModelProviders.of(this).get(SplashViewModel::class.java)
        setContentView(R.layout.activity_splash)
        bindProgressDialog()
        bindErrorSnackbar()
        viewModel.login()
    }

    private fun bindProgressDialog() {
        progressDialog = ProgressDialog(this)
        progressDialog.isIndeterminate = true
        progressDialog.setCancelable(false)
        progressDialog.setCanceledOnTouchOutside(false)
        progressDialog.setMessage("Loading Data...")
        viewModel.state.observe(this, Observer { loginState ->
            when(loginState) {
                SplashViewModel.State.WAITING_USER -> hideProgress()
                SplashViewModel.State.ATTEMPTING_LOGIN -> showProgress()
                SplashViewModel.State.AUTHENTICATED -> goToMainActivity()
            }
        })
    }

    private fun bindErrorSnackbar() {
        viewModel.error.observe(this, Observer { errorMsg ->
            if(errorMsg != null) {
                showConnectionError(errorMsg)
            }
        })
    }

    private fun goToMainActivity() {
        hideProgress()
        startActivity<ConferenceActivity>()
        finish()
    }

    private fun showConnectionError(error: String) {
        val snackbar = Snackbar.make(snackbar_container, error, Snackbar.LENGTH_LONG)
        snackbar.show()
    }

    private fun showProgress() {
        progressDialog.show();
    }

    private fun hideProgress() {
        progressDialog.dismiss();
    }


}
