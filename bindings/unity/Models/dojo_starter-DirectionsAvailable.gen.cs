// Generated by dojo-bindgen on Mon, 2 Dec 2024 16:54:58 +0000. Do not modify this file manually.
using System;
using Dojo;
using Dojo.Starknet;
using System.Reflection;
using System.Linq;
using System.Collections.Generic;
using Enum = Dojo.Starknet.Enum;

// Type definition for `core::byte_array::ByteArray` struct
[Serializable]
public struct ByteArray {
    public string[] data;
    public FieldElement pending_word;
    public uint pending_word_len;
}

// Type definition for `dojo_starter::models::DirectionsAvailableValue` struct
[Serializable]
public struct DirectionsAvailableValue {
    public Direction[] directions;
}

// Type definition for `dojo::meta::introspect::Enum` struct
[Serializable]
public struct Enum {
    public FieldElement name;
    public FieldElement[] attrs;
    public (FieldElement, Ty)[] children;
}

// Type definition for `dojo::meta::layout::FieldLayout` struct
[Serializable]
public struct FieldLayout {
    public FieldElement selector;
    public Layout layout;
}

// Type definition for `dojo::meta::introspect::Member` struct
[Serializable]
public struct Member {
    public FieldElement name;
    public FieldElement[] attrs;
    public Ty ty;
}

// Type definition for `dojo::model::definition::ModelDef` struct
[Serializable]
public struct ModelDef {
    public string name;
    public byte version;
    public Layout layout;
    public Ty schema;
    public Option<uint> packed_size;
    public Option<uint> unpacked_size;
}

// Type definition for `dojo::meta::introspect::Struct` struct
[Serializable]
public struct Struct {
    public FieldElement name;
    public FieldElement[] attrs;
    public Member[] children;
}

// Type definition for `dojo_starter::models::Direction` enum
public abstract record Direction() : Enum {
    public record None() : Direction;
    public record Left() : Direction;
    public record Right() : Direction;
    public record Up() : Direction;
    public record Down() : Direction;
}

// Type definition for `dojo::meta::layout::Layout` enum
public abstract record Layout() : Enum {
    public record Fixed(byte[] value) : Layout;
    public record Struct(FieldLayout[] value) : Layout;
    public record Tuple(Layout[] value) : Layout;
    public record Array(Layout[] value) : Layout;
    public record ByteArray() : Layout;
    public record Enum(FieldLayout[] value) : Layout;
}

// Type definition for `core::option::Option::<core::integer::u32>` enum
public abstract record Option<A>() : Enum {
    public record Some(A value) : Option<A>;
    public record None() : Option<A>;
}

// Type definition for `dojo::meta::introspect::Ty` enum
public abstract record Ty() : Enum {
    public record Primitive(FieldElement value) : Ty;
    public record Struct(Struct value) : Ty;
    public record Enum(Enum value) : Ty;
    public record Tuple(Ty[] value) : Ty;
    public record Array(Ty[] value) : Ty;
    public record ByteArray() : Ty;
}


namespace dojo_starter {
    // Model definition for `dojo_starter::models::DirectionsAvailable` model
    public class DirectionsAvailable : ModelInstance {
        [ModelField("player")]
        public FieldElement player;

        [ModelField("directions")]
        public Direction[] directions;

        // Start is called before the first frame update
        void Start() {
        }
    
        // Update is called once per frame
        void Update() {
        }
    }
}

        