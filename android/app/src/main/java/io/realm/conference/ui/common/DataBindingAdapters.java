package io.realm.conference.ui.common;


import android.databinding.BindingAdapter;
import android.graphics.drawable.Drawable;
import android.support.design.widget.FloatingActionButton;
import android.text.method.LinkMovementMethod;
import android.util.StateSet;
import android.widget.ImageView;
import android.widget.TextView;

import com.bumptech.glide.Glide;

import io.realm.conference.R;

public class DataBindingAdapters {

    @BindingAdapter({"app:imageUrl", "app:placeholder"})
    public static void loadImage(ImageView view, String url, Drawable placeholder) {
        if(url == null || url.equals("")) {
            url = "http://realm.io";
        }
        Glide.with(view.getContext())
                .load(url)
                .into(view);

    }

    @BindingAdapter({"app:followLinks"})
    public static void followLink(TextView textView, boolean followLinks) {
        if(followLinks) {
            textView.setMovementMethod(LinkMovementMethod.getInstance());
        }
    }
    
}
