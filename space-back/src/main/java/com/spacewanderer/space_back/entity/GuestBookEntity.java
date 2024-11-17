package com.spacewanderer.space_back.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@Entity(name = "guest_book")
@Table(name = "guest_book")
public class GuestBookEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "guest_book_id")
    private Long guestBookId;

    @Column(name = "author_anonymity")
    private boolean authorAnonymity;

    @Column(name = "write_date")
    private String writeDate;

    @Column(name = "content")
    private String content;

    @Column(name = "favorite_count")
    private int favoriteCount;

    @Column(name = "view_count")
    private int viewCount;

    @ManyToOne
    @JoinColumn(name = "planet_id", referencedColumnName = "planet_id")
    private PlanetEntity planet;

    @ManyToOne
    @JoinColumn(name = "author_unique_id", referencedColumnName = "user_unique_id")
    private UserEntity author;

    // 생성자 (작성일자와 내용은 필수, 다른 값은 기본값으로 설정 가능)
    public GuestBookEntity(boolean authorAnonymity, String writeDate, String content, int favoriteCount, int viewCount, PlanetEntity planet, UserEntity author) {
        this.authorAnonymity = authorAnonymity;
        this.writeDate = writeDate;
        this.content = content;
        this.favoriteCount = favoriteCount;
        this.viewCount = viewCount;
        this.planet = planet;
        this.author = author;
    }

    public UserEntity getAuthor() {
        return author;
    }
}
