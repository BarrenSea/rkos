use std::{env, path::PathBuf};
fn main() {
    if env::var("CARGO_CFG_TARGET_ARCH").unwrap_or_default() == "x86_64" {
        let manifest_dir = PathBuf::from(env::var("CARGO_MANIFEST_DIR").unwrap());
        // link scripts in rkos-arch/src/x86
        let link_ld_path = manifest_dir
            .parent()
            .unwrap()
            .join("rkos-arch")
            .join("src")
            .join("x86")
            .join("link.ld");
        println!("cargo:rustc-link-arg=-T{}", link_ld_path.display());
    }
}
