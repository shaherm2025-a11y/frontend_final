import os
import requests

# إنشاء مجلد الصور
os.makedirs("assets/images", exist_ok=True)

# قائمة الصور (الاسم : الرابط)
images = {
    # 🌱 أيقونات النباتات
    "tomato_icon.png": "https://cdn-icons-png.flaticon.com/512/415/415733.png",
    "potato_icon.png": "https://cdn-icons-png.flaticon.com/512/616/616408.png",
    "wheat_icon.png": "https://cdn-icons-png.flaticon.com/512/2919/2919439.png",
    "corn_icon.png": "https://cdn-icons-png.flaticon.com/512/2919/2919460.png",
    "pepper_icon.png": "https://cdn-icons-png.flaticon.com/512/616/616408.png",
    "cucumber_icon.png": "https://cdn-icons-png.flaticon.com/512/616/616408.png",

    # 🦠 أمراض الطماطم
    "tomato_wilt.png": "https://cdn-icons-png.flaticon.com/512/2909/2909763.png",
    "tomato_powder.png": "https://cdn-icons-png.flaticon.com/512/616/616408.png",
    "aphids.png": "https://cdn-icons-png.flaticon.com/512/2913/2913465.png",
    "whitefly.png": "https://cdn-icons-png.flaticon.com/512/2913/2913469.png",
    "tomato_blight.png": "https://cdn-icons-png.flaticon.com/512/2909/2909765.png",
    "blossom_rot.png": "https://cdn-icons-png.flaticon.com/512/415/415733.png",
    "gray_mold.png": "https://cdn-icons-png.flaticon.com/512/3050/3050525.png",

    # 🥔 أمراض البطاطس
    "potato_blight.png": "https://cdn-icons-png.flaticon.com/512/2909/2909765.png",
    "beetle.png": "https://cdn-icons-png.flaticon.com/512/616/616408.png",

    # 🌾 أمراض القمح
    "yellow_rust.png": "https://cdn-icons-png.flaticon.com/512/3050/3050525.png",
    "wheat_powder.png": "https://cdn-icons-png.flaticon.com/512/616/616408.png",
    "smut.png": "https://cdn-icons-png.flaticon.com/512/2919/2919410.png",

    # 🌽 أمراض الذرة
    "armyworm.png": "https://cdn-icons-png.flaticon.com/512/616/616408.png",
    "fusarium.png": "https://cdn-icons-png.flaticon.com/512/3050/3050525.png",

    # 🌶️ أمراض الفلفل
    "pepper_wilt.png": "https://cdn-icons-png.flaticon.com/512/2909/2909763.png",
    "red_spider.png": "https://cdn-icons-png.flaticon.com/512/2913/2913465.png",

    # 🥒 أمراض الخيار
    "downy_mildew.png": "https://cdn-icons-png.flaticon.com/512/616/616408.png",
    "bacterial_wilt.png": "https://cdn-icons-png.flaticon.com/512/2909/2909763.png",
}

# تحميل الصور
for name, url in images.items():
    path = os.path.join("assets/images", name)
    try:
        r = requests.get(url, timeout=10)
        r.raise_for_status()
        with open(path, "wb") as f:
            f.write(r.content)
        print(f"✅ تم تنزيل: {name}")
    except Exception as e:
        print(f"❌ فشل تنزيل {name}: {e}")
